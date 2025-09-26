const express = require("express");
const app = express();
const port = process.env.PORT || 3000;

app.get("/", (req, res) => {
  res.send("Hello from Pruthvi and Welcome to the DevOps CI/CD Project 🚀");
});

app.listen(port, () => {
  console.log(`App running at http://localhost:${port}`);
});
