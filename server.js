const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

// ✅ Connect to MySQL Database
const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
});

db.connect((err) => {
  if (err) {
    console.error("❌ MySQL Connection Failed:", err);
    return;
  }
  console.log("✅ MySQL Connected...");
});

// ✅ User Registration
app.post("/register", (req, res) => {
  const { firstName, lastName, email, password, dob } = req.body;

  // Check if email already exists
  db.query("SELECT * FROM users WHERE email = ?", [email], (err, results) => {
    if (err) return res.status(500).json({ message: "Database error" });
    if (results.length > 0) return res.status(400).json({ message: "Email already registered" });

    // Hash password and save user
    const hashedPassword = bcrypt.hashSync(password, 10);
    db.query(
      "INSERT INTO users (firstName, lastName, email, password, dob) VALUES (?, ?, ?, ?, ?)",
      [firstName, lastName, email, hashedPassword, dob],
      (err, result) => {
        if (err) return res.status(500).json({ message: "Error registering user" });
        res.status(201).json({ message: "User registered successfully" });
      }
    );
  });
});

// ✅ User Login
app.post("/login", (req, res) => {
  const { email, password } = req.body;

  db.query("SELECT * FROM users WHERE email = ?", [email], (err, results) => {
    if (err) return res.status(500).json({ message: "Database error" });
    if (results.length === 0) return res.status(401).json({ message: "User not found" });

    // Check password
    const validPassword = bcrypt.compareSync(password, results[0].password);
    if (!validPassword) return res.status(401).json({ message: "Incorrect password" });

    // Generate JWT Token
    const token = jwt.sign({ id: results[0].id }, process.env.JWT_SECRET, { expiresIn: "1h" });

    res.json({ message: "Login successful", token });
  });
});

// ✅ Fetch All Visitors
app.get("/visitors", (req, res) => {
  db.query("SELECT * FROM visitors", (err, results) => {
    if (err) return res.status(500).json({ message: "Error fetching visitors" });
    res.json(results);
  });
});

// ✅ Add a Visitor
app.post("/visitors", (req, res) => {
  const { name, relation, reason } = req.body;
  db.query(
    "INSERT INTO visitors (name, relation, reason) VALUES (?, ?, ?)",
    [name, relation, reason],
    (err, result) => {
      if (err) return res.status(500).json({ message: "Error adding visitor" });
      res.status(201).json({ message: "Visitor added successfully" });
    }
  );
});

// ✅ Delete a Visitor
app.delete("/visitors/:id", (req, res) => {
  const { id } = req.params;
  db.query("DELETE FROM visitors WHERE id = ?", [id], (err, result) => {
    if (err) return res.status(500).json({ message: "Error deleting visitor" });
    res.json({ message: "Visitor deleted successfully" });
  });
});

// ✅ Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
