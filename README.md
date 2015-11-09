Paginative
==========

## Version 0.3.1

The current README refers to version 0.3.1 at the current `master` branch.

### A different way to paginate your Rails API.

Paginative came about when building a Rails backend for an iOS app and needed a better way to fetch paginated results while keepping track of whats been deleted from the backend.

Instead of using the usual lookup method of IDs, **Paginative** allows for the lookup of records from a name or distance (reliant on the excellent [Geocoder](https://github.com/alexreisner/geocoder) gem). This means that even if the reference object you are looking up has been deleted from the Backend, the pagination will still work seemlessly, especially when paired with the [Ragamuffins](https://github.com/RustComet/Ragamuffins) gem for returning the deleted IDs.

Installation
---------------

### Rails 3.2

I have moved the dependency down to 3.2 for the github version of the gem, but not the ruby gems version (until tested). In the mean time you can include the gem straight from this repository.

**PLEASE NOTE:** This version has not been properly tested with 3.2. If you run into problems please open an issue and I will have a look into it.

`gem "paginative", github: "RustComet/paginative"`

`bundle install`

### Rails >= 4.0

Nothing fancy, just include the gem in your gem file:

`gem "paginative"`

and run `bundle install`.

And you're good to go.

Getting Started
---------------

Once the gem is installed all you need to do is include the methods on your model:

```
class YourModel < ActiveRecord::Base
  include Paginative::ModelExtension

end
```

Doing this will give you 2 extra class methods for your model; `YourModel.with_name_from(name)` and `YourModel.by_distance_from(latitude, longitude, distance)`.

Both of these calls are explained below.

### By Name

This is a way to paginate by name, and is the simpler of the methods. It allows to to pass in a name, and return the next page of records from that name. So as a basic example say you had a collection of `YourModel` with a `:name` column filled with "A" through to "Z", and wanted to get back everything from the name "M" you would simply call

This method will also automatically sort your orders by name to save you doing it yourself.

```
YourModel.with_name_from("M")
```

and the gem will return all the records that `>` the letter "M". So in this case:

```
models = YourModel.all

new_collection = models.with_name_from("M")

new_collection.map(&:name)

=> ["N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
```

### By Distance

*This relies on a model been Geocoded, and having a `:latitude` and `:longitude` column on the model so that it can calculate the distance. The gem itself will be installed as a dependency, but it's worth checking out the documentation [here](https://github.com/alexreisner/geocoder) if you haven't already*

This allows you to paginate your records by distance. Simply pass in the co-ordinates, and the distance you want to start at, and the gem will do the rest.

```
models = YourModel.all

models.by_distance_from(latitude, longitude, distance)
```

This will return the next page of objects that are further away than the distance passed in. So if you are doing a nearby sort, and you need the next page, all you have to do is pass in the distance that the last object on the page from your current `:latitude` and `:longitude` and it will give you the next page of results.

### By a Custom Field

Lets say you want to sort by something other than name or distance, well Paginative has you covered.

```
models = YourModel.all

models.with_field_from("id", 1)
```

This will return all models that have an ID greater than 1, ordered by ID. Any column can be passed in, and the results will automatically be ordered by that column.

### Allowed Paginative Fields

Introduced in `0.3.0`, we've added a class method, `allow_paginative_on`, that allows you to whitelist the fields that you want to open up pagination on in your queries using `with_field_from`. By default, *no fields* are open for pagination using `with_field_from`, so you'll need to specify the ones you want to use before you can paginate anything with that method.

Fields can be specified as symbols, which get mapped to the table of the current class:
```ruby
class YourModel < ActiveRecord::Base
  include Paginative::ModelExtension

  allow_paginative_on :created_at
    #=> Allows you to paginate on `your_models.created_at`.
end
```

Or they can be specified as hashes, using the mapping you choose:
```ruby
class YourModel < ActiveRecord::Base
  include Paginative::ModelExtension

  allow_paginative_on created_at: 'your_models.created_at'
    #=> Allows you to paginate on `your_models.created_at`.
end
```

Or a combination:
```ruby
class YourModel < ActiveRecord::Base
  include Paginative::ModelExtension

  allow_paginative_on :id, created_at: 'your_models.created_at'
    #=> Pagination on `your_models.id` and `your_models.created_at`
end
```

The main use case in using the hash-style of specifying your paginative fields is to allow pagination on a joint table:
```ruby
class YourModel < ActiveRecord::Base
  include Paginative::ModelExtension

  has_many :other_models

  allow_paginative_on created_at: 'other_models.created_at'
    #=> Pagination on `other_models.created_at`

  class << self
    def with_other_models
      joins(:other_models).select('your_models.*, other_models.created_at')
    end
  end
end

class OtherModel < ActiveRecord::Base
end
```
The above would allow you to fetch all of your models that have the join, but order by the creation time of the associated objects.

### With more than 1 sort option

Sometimes when you are paginating by a custom field there will be times when you need a secondary sort method. Paginative handles this by allowing the arguments to passed in as arrays.

Given the example below:

```
Person.all
    { first_name: Andrew, last_name: Burrows }
    { first_name: Andrew, last_name: Chaplin }
    { first_name: Andrew, last_name: Newton }
    { first_name: Bradley, last_name: Andrews }
    { first_name: Howard, last_name: Moon }
```

And you want to return only the records _after_ Andrew Chaplin, you can do so in the following way:

```
Person.with_field_from(["first_name", "last_name"], ["Andrew", "Chaplin"])
```

This will order the `Person` object by `first_name `, and then `last_name` and return the objects accordingly.

Options & Defaults
------------------

### Results per page

All methods default to returning `25` results per page (or call). But this can be overridden by passing in an extra argument to the call.

```
YourModel.with_name_from(name, limit_per_page)
YourModel.by_distance_from(latitude, longitude, distance, limit_per_page)
YourModel.with_field_from(field, from, limit_per_page)
```

This means that if you only want to fetch records one at a time you could do so by calling `YourModel.with_name_from(name, 1)`.

If you do not pass in a `name` argument, it will default to nothing and give you the first 25 objects back.

Also if you do not pass a `distance` in as an argument, it will assume that you are starting at the start and default to 0.

### Ordering

You can now pass in a final argument if you would like to reverse the order of thr results (sort by `desc` instead of `asc`).

```
YourModel.with_name_from(name, limit_per_page, order)
YourModel.with_field_from(field, from, limit_per_page, order)
```

This is as simple as passing in the string `"desc"` as your final argument in the call.

eg.

```
models = YourModel.all

new_collection = models.with_name_from("M", 25, "desc")

new_collection.map(&:name)

=> ["L", "K", "J", "I", "H", "G", "F", "E", "D", "C", "B", "A"]
```

The same works for the custom fields, but not for distance. Distance is onlt ever sorted ascending.

TO DO:
------

* Better "limits" to pages, done in a cleaner way.
* Clean up the methods so they just take an options hash instead of requiring all the arguments in the methods

Contributing
------------

If you have any ideas feel free to open an issue or even better, write it yourself and issue a pull request. Please write some tests for the code you have written.

