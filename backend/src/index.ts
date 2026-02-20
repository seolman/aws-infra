import express from "express";

// TODO postgres
// TODO redis
// TODO sns

const app = express();

app.use(express.urlencoded({
    extended: true,
}));

app.use(express.json())

app.get("/api/cache", async (req, res) => {
    // TODO check redis

    const data = {
        // TODO
        message: "hello",
        timestamp: new Date()
    }

    // TODO set key

    res.send({
        source: "db",
        data: data
    })
});

app.post("/api/users", async (req, res) => {
    const { username, email } = req.body;
})

app.get("/health", (req, res) => {
    res.send({
        message: "ok"
    });
});

app.listen(80, () => {
    console.log("server start http://localhost:80");
});

