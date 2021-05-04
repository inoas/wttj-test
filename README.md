# WTTJ Test

A pure script solution might have been faster to create but I like to confirm that everything works logically and simple UIs help me with that, especially because I haven't worked with postgres-gis before this project.

## On question 02/03

There are multiple ways to make sure the solution performs under heavy write/read.

For the statistics page:

- a simple HTTP get cache will  work as there are no queries modifying the result.
- with the solution I have given, liveview + query cache OR page reload via xhr-polling + http cache may work

For the job finder I can imagine:

- ETS based SQL query cache and/or
- Using SQL explain / improving database indexes
- Using a replication system such as main<>replicant (aka master-slave) replication in postgres
- For single item views: moving whole 'documents' (data views of sql joins) as blocks into some no-sql layer for reading/cache

## A note on import files

In the docs dir you will find 2 of the supplied csv files and one json file I found on the web which was required to map coords to continents as open street maps does not yield that information, positionstack did 503 and google maps (which might have yielded continental associations to geo coords) required a non-prepaid credit card.

# Phoenix

To start your Phoenix server:

* Install dependencies with `mix deps.get`
* Create and migrate your database with `mix ecto.setup`
* Install Node.js dependencies with `npm install` inside the `assets` directory
* Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

### Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
