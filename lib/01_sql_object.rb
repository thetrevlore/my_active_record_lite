require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    unless @cols
      @cols = DBConnection.execute2("SELECT * FROM #{self.table_name}").first
    end
    @cols.map { |col_name| col_name.to_sym }
  end

  def self.finalize!
    self.columns.each do |attribute|
      define_method("#{attribute}") do
        self.attributes[attribute]
      end
      define_method("#{attribute}=") do |val|
        self.attributes[attribute] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ? @table_name : "#{self}".tableize
  end

  def self.all
    self.parse_all(DBConnection.execute("SELECT * FROM #{self.table_name}"))
  end

  def self.parse_all(results)
    results.map { |hash| self.new(hash) }
  end

  def self.find(id)
    thing = DBConnection.execute(<<-SQL, id)
      SELECT *
      FROM #{self.table_name}
      WHERE id = ?
      SQL
      self.parse_all(thing).first
  end

  def initialize(params = {})
    params.each do |attr_name, attr_val|
      attr_sym = attr_name.to_sym
      raise "unknown attribute '#{attr_sym}'" unless self.class.columns.include? attr_sym
      self.send("#{attr_sym}=", attr_val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |column| self.send(column) }
  end

  def insert
    col_names = self.class.columns.join(",")
    question_marks = []
    self.class.columns.length.times { |i| question_marks << '?' }
    question_marks = question_marks.join(",")

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

  end

  def update
    # ...
  end

  def save
    # ...
  end
end
