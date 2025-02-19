class Dog 
  attr_accessor :name, :breed, :id
  
  def initialize(id:nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end 
  
  def self.create_table 
    sql = <<-SQL
      CREATE TABLE dogs (
      id INTEGER,
      name TEXT,
      breed TEXT
      )
      SQL
      DB[:conn].execute(sql)
  end 
  
  def self.drop_table 
    sql = <<-SQL 
    DROP TABLE dogs 
    SQL
    
    DB[:conn].execute(sql)
  end 
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end 
  
  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save 
    dog
  end
  
  def self.new_from_db(row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    Dog.new(result[0], result[1], result[2])
  end
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog = self.new_from_db(dog[0])
    else 
      dog = self.create(name: name, breed: breed)
    end   
    dog  
  end 
  
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * 
    FROM dogs 
    WHERE name = ?
    SQL
    result = DB[:conn].execute(sql, name).flatten
    self.new_from_db(result)
  end
  
  def update 
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
end 