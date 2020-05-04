class Dog
    attr_accessor :name, :breed
    attr_reader :id
    def initialize(name: name, breed: breed, id: id = nil)
        @name = name
        @breed = breed
        @id = id        
    end

    def self.create_table
        DB[:conn].execute('DROP TABLE IF EXISTS dogs')

        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);
        SQL
        
        DB[:conn].execute(sql)

    end

    def self.drop_table
        DB[:conn].execute('DROP TABLE IF EXISTS dogs')

    end

    def save
        if @id
            self.update
        else                      
            sql = "INSERT INTO dogs(name, breed) VALUES (? , ?);"
            DB[:conn].execute(sql, self.name, self.breed)

            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
        end
        self
    end

    def self.create(name:name, breed:breed)
        new_dog= self.new(name:name, breed:breed)
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = "SELECT id, name, breed FROM dogs WHERE id = ? LIMIT 1;"

        dog_data = DB[:conn].execute(sql, id).first

        self.new_from_db(dog_data)
    end

    def self.find_or_create_by(name: name, breed: breed = nil)

        # if breed        
            sql = "SELECT id, name, breed FROM dogs WHERE name = ? AND breed = ? LIMIT 1;"
            dog_data = DB[:conn].execute(sql, name, breed).first
        # # else
            # sql = "SELECT id, name, breed FROM dogs WHERE name = ? LIMIT 1;"
            # dog_data = DB[:conn].execute(sql, name).first
        # end

        if dog_data
            new_dog = self.new_from_db(dog_data)
        else
            new_dog = self.new(name: name, breed: breed)
            new_dog.save
        end
        new_dog
    end
        

    def self.find_by_name(name)
        sql = "SELECT id, name, breed FROM dogs WHERE name = ? LIMIT 1;"
        dog_data = DB[:conn].execute(sql, name).first

        if dog_data
            new_dog = self.new_from_db(dog_data)
        else
            new_dog = nil
        end
        new_dog
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed =? WHERE id = ?;"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
        






end

