# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

r1 = Category.create(name: "Root 1")
r2 = Category.create(name: "Root 2")
r3 = Category.create(name: "Root 3")

r1a = r1.child_categories.create(name: "R1A")
r1b = r1.child_categories.create(name: "R1B")
r2a = r1.child_categories.create(name: "R2A")
