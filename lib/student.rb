class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    new_student = self.new
    new_student.id = row[0]
    new_student.name = row[1]
    new_student.grade = row[2]
    new_student
    #convert what database gives us into a Ruby object
    #SQLite returns an array of data for each row
  end

  def self.all
    sql = <<-SQL
      SELECT *
      FROM students
    SQL
    #everything between <<-SQL - SQL is stored in variable sql & executed in below statement
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
    #sql is executed in database, new array with rows turned into Ruby objects are returned
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL
    #use ? where want name parameter to be passed in & include name as the second argument to execute the method
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
    #Return value of .map is an array and we're grabbing the first element
  end

  def save
    #saves the attributes describing a given student to students table in database
    #saves an instance variable that has already been created-- that's why it doesn't need any arguments
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    #pass in self.name & self.grade into ?'s

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    #the tests pass without this line^ ??
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL
    #creates students table with id, name, and grade columns
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def self.all_students_in_grade_9
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE grade = 9;
    SQL
    DB[:conn].execute(sql).collect do |row|
      self.new_from_db(row)
    end
  end

  def self.students_below_12th_grade
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE grade < 12
    SQL
    DB[:conn].execute(sql).collect do |row|
      self.new_from_db(row)
    end
  end

  def self.first_X_students_in_grade_10(x)

    sql = <<-SQL
      SELECT *
      FROM students
      WHERE grade = 10
      LIMIT ?
    SQL
    #again,use ? where want name parameter to be passed in & include name as the second argument to execute the method
    DB[:conn].execute(sql, x).collect do |row|
      self.new_from_db(row)
    end
  end

  def self.first_student_in_grade_10
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE grade = 10
      LIMIT 1
    SQL
    DB[:conn].execute(sql).collect do |row|
      self.new_from_db(row)
    end.first
  end

  def self.all_students_in_grade_X(x)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE grade = ?
    SQL
    DB[:conn].execute(sql, x).collect do |row|
      self.new_from_db(row)
    end
  end

end
