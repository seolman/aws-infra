import express, { Request, Response, NextFunction } from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { eq } from "drizzle-orm";

import { db } from "./db/index.js";
import { users } from "./db/schema.js";

const app = express();
const JWT_SECRET = process.env.JWT_SECRET || "demo-secret-key";

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

// Profile
app.get("/api/profile", authenticateToken, async (req: Request, res: Response) => {
  const user = (req as any).user;
  res.json({ user });
});

app.get("/health", (req, res) => {
  res.json({ message: "ok" });
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`server start http://localhost:${PORT}`);
});
