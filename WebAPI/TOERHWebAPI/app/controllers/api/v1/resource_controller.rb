class Api::V1::ResourceController < ApplicationController
	before_filter :validateApiKey
	before_filter :validateUser, :except => [:index, :show]
	
	# GET: api/v1/resource?apikey=s4ciD75L69UAXz0y8QrhJfbNVOm3T21wGkpe&resourcename=Test&limit=10&page=1
	def index
		resources = nil
		if params[:resourcename].blank? == false
			query = "%#{params[:resourcename]}%"
			if params[:limit].blank? == false
				if params[:page].blank? == false
					resources = Resource.where("name LIKE ?", query).paginate(page: params[:page], per_page: params[:limit])
				else
					resources = Resource.where("name LIKE ?", query).limit(params[:limit].to_i)
				end
			elsif params[:page].blank? == false
				resources = Resource.where("name LIKE ?", query).paginate(page: params[:page], per_page: 10)
			else
				resources = Resource.where("name LIKE ?", query)
			end
		elsif params[:limit].blank? == false
			if params[:page].blank? == false
				resources = Resource.all.paginate(page: params[:page], per_page: params[:limit])
			else
				resources = Resource.all.limit(params[:limit].to_i)
			end
		elsif params[:page].blank? == false
			resources = Resource.all.paginate(page: params[:page], per_page: 10)
		else
			resources = Resource.all
		end
		
		if resources.blank? == false
			resultArray = Array.new
			resultHash = Hash.new
			resources.each do |resource|
				resultArray << generateResourceHash(resource)
			end
			resultHash["status"]=200
			resultHash["resources"]=resultArray
			if params[:page].blank? == false
				resultHash["nextPage"]=changePageLink("resource", false)
				resultHash["previousPage"]=changePageLink("resource", true)
			end
			respond_to do |f|
				f.json { render json: resultHash, :status => 200 }
				f.xml { render xml: resultHash, :status => 200 }
			end
		else
			errorHash = Hash.new
			errorHash["status"] = 404
			errorHash["errormessage"] = "Found no resources"
			respond_to do |f|
				f.json { render json: errorHash, :status => 404 }
				f.xml { render xml: errorHash, :status => 404 }
			end
		end
	end

	# GET: api/v1/resource/:id?apikey=s4ciD75L69UAXz0y8QrhJfbNVOm3T21wGkpe
	def show
		begin
			resource = Resource.find(params[:id])
			resultHash = Hash.new
			resultHash["status"]=200
			resultHash["resource"]=generateResourceHash(resource)
			respond_to do |f|
				f.json { render json: resultHash, :status => 200 }
				f.xml { render xml: resultHash, :status => 200 }
			end
		rescue
			errorHash = Hash.new
			errorHash["status"] = 404
			errorHash["errormessage"] = "Resource not found"
			respond_to do |f|
				f.json { render json: errorHash, :status => 404 }
				f.xml { render xml: errorHash, :status => 404 }
			end
		end
	end
	
	# POST: api/v1/resource?apikey=s4ciD75L69UAXz0y8QrhJfbNVOm3T21wGkpe
	def create
		resourcetypeparam = params[:resource_type]
		licencetypeparam = params[:licence]
		description = " "
		if params[:description].blank? == false
			description = params[:description]
		end
		url = params[:url]
		tags = params[:tags]
		name = params[:resource_name]
		
		if name.blank? == false && licencetypeparam.blank? == false && resourcetypeparam.blank? == false && url.blank? == false
			user = User.find_by_username(@@current_username)
			licencetype = Licence.find_or_create_by_licence_type(licencetypeparam)
			resourcetype = ResourceType.find_or_create_by_resource_type(resourcetypeparam)
			resource = Resource.new
			resource.name = name
			resource.resource_type_id = resourcetype.id
			resource.user_id = user.id
			resource.licence_id = licencetype.id
			resource.description = description
			resource.url = url
			resource.created_at = DateTime.now
			resource.updated_at = DateTime.now
			tags.each do |tag|
				tagInfo = Tag.find_or_create_by_tag(tag)
				resource.tags << tagInfo
			end
			if resource.save
				resultHash = Hash.new
				resultHash["status"]=201
				resultHash["resource"]=generateResourceHash(resource)
				respond_to do |f|
					f.json { render json: resultHash, :status => 201 }
					f.xml { render xml: resultHash, :status => 201 }
				end
			else
				errorHash = Hash.new
				errorHash["status"] = 400
				errorHash["errormessage"] = "Parameters did not pass validation"
				respond_to do |f|
					f.json { render json: errorHash, :status => 400 }
					f.xml { render xml: errorHash, :status => 400 }
				end
			end
		else
			errorHash = Hash.new
			errorHash["status"] = 400
			errorHash["errormessage"] = "Required parameters missing"
			respond_to do |f|
				f.json { render json: errorHash, :status => 400 }
				f.xml { render xml: errorHash, :status => 400 }
			end
		end
	end
	
	# PUT: api/v1/resource/:id?apikey=s4ciD75L69UAXz0y8QrhJfbNVOm3T21wGkpe
	def update
		begin
			resource = Resource.find(params[:id])
			resourcetypeparam = params[:resource_type]
			licencetypeparam = params[:licence]
			url = params[:url]
			tags = params[:tags]
			name = params[:resource_name]
			if resourcetypeparam.blank? == false
				resource_type = ResourceType.find_or_create_by_resource_type(resourcetypeparam)
				resource.resource_type_id = resource_type.id
			end
			if licencetypeparam.blank? == false
				licence = Licence.find_or_create_by_licence_type(licencetypeparam)
				resource.licence_id = licence.id
			end
			if params[:description].blank? == false
				resource.description = params[:description]
			end
			if url.blank? == false
				resource.url = url
			end
			if name.blank? == false
				resource.name = name
			end
			if tags.blank? == false
				resource.tags = Array.new
				tags.each do |tag|
					tagInfo = Tag.find_or_create_by_tag(tag)
					resource.tags << tagInfo
				end
			end
			user = User.find_by_username(@@current_username)
			if user.id == resource.user_id
				resource.updated_at = DateTime.now
				if resource.save
					resultHash = Hash.new
					resultHash["status"]=200
					resultHash["resource"]=generateResourceHash(resource)
					respond_to do |f|
						f.json { render json: resultHash, :status => 200 }
						f.xml { render xml: resultHash, :status => 200 }
					end
				else
					errorHash = Hash.new
					errorHash["status"] = 400
					errorHash["errormessage"] = "Parameters did not pass validation"
					respond_to do |f|
						f.json { render json: errorHash, :status => 400 }
						f.xml { render xml: errorHash, :status => 400 }
					end
				end
			else
				errorHash = Hash.new
				errorHash["status"] = 403
				errorHash["errormessage"] = "Current user does not have access to this resource"
				respond_to do |f|
					f.json { render json: errorHash, :status => 403 }
					f.xml { render xml: errorHash, :status => 403 }
				end
			end
		rescue
			errorHash = Hash.new
			errorHash["status"] = 404
			errorHash["errormessage"] = "Did not find the requested resource"
			respond_to do |f|
				f.json { render json: errorHash, :status => 404 }
				f.xml { render xml: errorHash, :status => 404 }
			end
		end		
	end
	
	# DELETE: api/v1/resource/:id?apikey=s4ciD75L69UAXz0y8QrhJfbNVOm3T21wGkpe
	def destroy
		begin
			resource = Resource.find(params[:id])
			user = User.find_by_username(@@current_username)
			if resource.user_id == user.id
				resource.destroy
				respond_to do |f|
					f.json { render :nothing => true, :status => 204 }
					f.xml { render :nothing => true, :status => 204 }
				end
			else
				errorHash = Hash.new
				errorHash["status"] = 403
				errorHash["errormessage"] = "User unauthorized"
				render :json => errorHash, :status => 403
			end
		rescue
			errorHash = Hash.new
			errorHash["status"] = 404
			errorHash["errormessage"] = "Resource not found"
			render :json => errorHash, :status => 404
		end
	end
end
