SoulWalrus Website
===

Setting up the server (Ruby on Rails [Arguably overkill] ):
---

1. Get Ruby + gems + rails http://www.tutorialspoint.com/ruby-on-rails/rails-installation.htm
or use a nice installer http://railsinstaller.org/en (Ruby 2.2)
2. Read up some docs http://www.tutorialspoint.com/ruby-on-rails/
3. run `bundle install` to install dependencies`
4. run `rails s Puma -e development` in the `server` folder
5. For production `rails s Puma -b 0.0.0.0 -e production`

`bundle clean --force` to remove unused gem dependencies.

Setting up the client: (Currently very basic implementation)
---

1. Get Nodejs
2. `npm install`
3. `gulp build`
4. `gulp webpack-dev-server`
