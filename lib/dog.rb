require 'pry'

class Dog

  attr_accessor :id, :name, :breed

  def initialize(attributes)
     attributes.each {|key, value| self.send(("#{key}="), value)}
  end

  def self.create_table
     sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
     SQL

     DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
       DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end


  def save
    if self.id
       self.update
    else
    sql = <<-SQL
       INSERT INTO dogs (name, breed)
       VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end


  def self.create(attributes)
     dog = Dog.new(attributes)
     dog.save
     dog
  end


  def self.new_from_db(row)
    new_dog = self.new(id:row[0],name:row[1], breed:row[2])
  end


  def self.find_by_id(id)
    sql = <<-SQL
       SELECT * FROM dogs
       WHERE id = ?
    SQL

    DB[:conn].execute(sql, id).map do |row|
       self.new_from_db(row)
    end.first
  end


  def self.find_or_create_by(attributes)
    #binding.pry
    if self.find_by_id(attributes[:id]) == nil
      self.create(attributes)
    else
       self.find_by_id(attributes[:id])
   end
  end


  def self.find_by_name(name)
    sql = <<-SQL
       SELECT * FROM dogs
       WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map do |row|
       self.new_from_db(row)
    end.first
  end


  def update
     sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
     DB[:conn].execute(sql, self.name, self.breed, self.id)
     #binding.pry
  end
end


# def self.find_or_create_by(attributes)
#   #binding.pry
#   dogs = self.find_by_name(attributes[:name])
#   if dogs == nil
#     self.create(attributes)
#   elsif dogs.length == 1
#      dogs[0]
#   else
#     dogs.find {|d| d.breed == attributes[:breed]}
#     #self.find_by_id(attributes[:id])
#  end
# end
