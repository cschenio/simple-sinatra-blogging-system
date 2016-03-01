require 'sinatra'
require 'sinatra/base'

require 'slim'
require 'rdiscount'

require 'sqlite3'
require 'sequel'


DB = Sequel.sqlite

DB.create_table :articles do
  primary_key :id
  string :title
  text :content
end

# Fake data

a = DB[:articles]
a.insert(:title => "Hello world!", :content => "<h2>aaa</h2> Quick brown fox <b>jumped</b> over the lazy dog.")
a.insert(:title => "Another hello world!", :content => "<h2>bbb</h2> Quick brown fox <i>jumped</i> over the lazy dog.")

# front end

['/','/articles'].each do |path|
  get path do
    slim :index, :locals => {:articles => DB[:articles]}
  end
end

get '/articles/:id' do |i|
  # markdown :"article#{i}"
  # slim :show , :locals => {:content => markdown(:"article#{i}") }
  slim :show, :locals => {:article => DB[:articles][:id => i]}
end

# back stage

['/admin', '/admin/articles'].each do |path|
  get path do
    slim :'admin/index', :locals => {:articles => DB[:articles]}
  end
end

get '/admin/articles/new' do
  slim :'admin/new'
end

post '/admin/articles' do
  DB[:articles].insert(:title => params[:title], :content => markdown(params[:content])) 
  redirect '/admin/articles'
end


get '/admin/articles/:id' do |i|
  slim :'admin/show', :locals => {:article => DB[:articles][:id => i]}
end

get '/admin/articles/:id/edit' do |i|
  slim :'admin/edit'
end

put '/admin/articles/:id' do |i|
  DB[:articles][:id => i].update(:title => params[:title], :content => params[:content])
  redirect '/admin/articles'
end

delete '/admin/articles/:id' do |i|
  DB[:articles][:id => i].delete
  redirect '/admin/articles'
end

__END__
