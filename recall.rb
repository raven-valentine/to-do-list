require 'sinatra'
require 'data_mapper'
require 'time'
#require 'rack-flash'
#require 'sinatra/redirect_with_flash'

class Note
	include DataMapper::Resource
	property :id, Serial
	property :content, Text, :required => true
	property :complete, Boolean, :required => true, :default => 0
	property :created_at, DateTime
	property :updated_at, DateTime
end

class Recall < Sinatra::Base


SITE_TITLE = "To do list"
SITE_DESCRIPTION = "..becoss i'm too busy to remember everything in my head"

enable :sessions
#use Rack::Flash, :sweep => true

DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/recall.db")
DataMapper.auto_upgrade!

helpers do
	include Rack::Utils
	alias_method :h, :escape_html
end


# 
# Application
#

get '/' do
	@notes = Note.all :order => :id.desc
	@title = 'All Notes'
	if @notes.empty?
#		flash[:error] = 'No notes found. Add your first below.'
	end 
	erb :home
end

post '/' do
	n = Note.new
	n.attributes = {
		:content => params[:content],
		:created_at => Time.now,
		:updated_at => Time.now
	}
	if n.save
		redirect '/'
	else
		redirect '/'
	end
end

get '/rss.xml' do
	@notes = Note.all :order => :id.desc
	builder :rss
end

get '/:id' do |id|
	@note = Note.get(id.to_i)
	@title = "Edit note ##{id}"
	if @note
		erb :edit
	else
		redirect '/'
	end
end

post '/:id' do |id|
	n = Note.get id.to_i
	unless n
		redirect '/'
	end
	n.attributes = {
		:content => params[:content],
		:complete => params[:complete] ? 1 : 0,
		:updated_at => Time.now
	}
	if n.save
		redirect '/'
	else
		redirect '/'
	end
end

get '/:id/delete' do |id|
	@note = Note.get id.to_i
	@title = "Confirm deletion of note ##{params[:id]}"
	if @note
		erb :delete
	else
		redirect '/'
	end
end

post '/:id/delete' do |id|
	n = Note.get id.to_i
	if n.destroy
		redirect '/'
	else
		redirect '/'
	end
end

get '/:id/complete' do |id|
	n = Note.get id.to_i
	unless n
		redirect '/'
	end
	n.attributes = {
		:complete => n.complete ? 0 : 1, # flip it
		:updated_at => Time.now
	}
	if n.save
		redirect '/'
	else
		redirect '/'
	end
end

end
