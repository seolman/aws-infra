import express, { Request, Response, NextFunction } from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { db } from "./db/index.js";
import { users } from "./db/schema.js";
import { eq } from "drizzle-orm";
import { Redis } from "ioredis";

const app = express();
const JWT_SECRET = process.env.JWT_SECRET || "demo-secret-key";

const redis = new Redis(process.env.REDIS_URL || "redis://localhost:6379")

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Auth Middleware
const authenticateToken = (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (!token) return res.status(401).json({ message: "Unauthorized" });

  jwt.verify(token, JWT_SECRET, (err: any, user: any) => {
    if (err) return res.status(403).json({ message: "Forbidden" });
    (req as any).user = user;
    next();
  });
};

// Signup
app.post("/api/signup", async (req: Request, res: Response) => {
  const { email, password } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = await db.insert(users).values({
      email,
      password: hashedPassword,
    }).returning({ id: users.id, email: users.email });

    // TODO aws sns

    const token = jwt.sign({ id: newUser[0].id, email: newUser[0].email }, JWT_SECRET);
    res.status(201).json({ user: newUser[0], token });
  } catch (error: any) {
    if (error.code === "23505") { // Unique violation
      return res.status(400).json({ message: "User already exists" });
    }
    res.status(500).json({ message: "Internal server error" });
  }
});

// Login
app.post("/api/login", async (req: Request, res: Response) => {
  const { email, password } = req.body;

  try {
    const user = await db.query.users.findFirst({
      where: eq(users.email, email),
    });

    if (!user || !(await bcrypt.compare(password, user.password))) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET);
    res.json({ user: { id: user.id, email: user.email }, token });
  } catch (error) {
    res.status(500).json({ message: "Internal server error" });
  }
});

// Profile with Redis Caching
app.get("/api/profile", authenticateToken, async (req: Request, res: Response) => {
  const userPayload = (req as any).user;
  const cacheKey = `user:profile:${userPayload.id}`;

  try {
    // 1. Try to get data from Redis
    const cachedUser = await redis.get(cacheKey);

    if (cachedUser) {
      console.log("Cache Hit: Returning from Redis");
      return res.json({ 
        user: JSON.parse(cachedUser),
        source: "cache" 
      });
    }

    // 2. If not in Redis, get from Database
    console.log("Cache Miss: Querying Database");
    const user = await db.query.users.findFirst({
      where: eq(users.id, userPayload.id),
    });

    if (!user) return res.status(404).json({ message: "User not found" });

    const userData = { id: user.id, email: user.email };

    // 3. Store in Redis for 1 hour
    await redis.set(cacheKey, JSON.stringify(userData), "EX", 3600);

    res.json({ 
      user: userData,
      source: "db" 
    });
  } catch (error) {
    console.error("Redis/DB Error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});

app.get("/health", (req, res) => {
  res.json({ message: "ok" });
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`server start http://localhost:${PORT}`);
});
