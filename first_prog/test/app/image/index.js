/* comment to see if pipeline works well */
  const express = require('express');
const { Client } = require('pg'); 
const app = express();
const port = 3000;


const client = new Client({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: 5432,
  ssl: {
    rejectUnauthorized: false     
  }
});

client.connect()
  .then(() => console.log('Connected to DB'))
  .catch(err => console.error('DB connection error:', err));

let counter = 0;

app.get('/', async (req, res) => {
  counter++;
  try {
    await client.query('CREATE TABLE IF NOT EXISTS visits(visit_number INT,visited_at TIMESTAMP);');
    await client.query('INSERT INTO visits(visit_number, visited_at) VALUES ($1, NOW())',
      [counter]
    );
    res.send(`<h1>Visits: ${counter}</h1>`);
  } catch (err) {
    res.send('Error saving to DB');
    console.error(err);
  }
});


app.listen(port, () => console.log(`App running on port ${port}`));
