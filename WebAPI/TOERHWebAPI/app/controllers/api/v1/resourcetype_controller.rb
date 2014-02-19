class Api::V1::ResourcetypeController < ApplicationController
	before_filter :validateApiKey
	
	# GET: api/v1/resourcetype?apikey=dsoumefehknkkxkumkkuzvmulclcdtkhcdwukbtg
	def index
		resourcetypes = ResourceType.all
		if resourcetypes != nil
			resultArray = Array.new
			resultHash = Hash.new
			resourcetypes.each do |resourcetype|
				resultArray << generateResourceTypeHash(resourcetype)
			end
			resultHash["status"]=200
			resultHash["resourcetypes"]=resultArray
			respond_to do |f|
				f.json { render json: resultHash, :status => 200 }
				f.xml { render xml: resultHash, :status => 200 }
			end
		else
			errorHash = Hash.new
			errorHash["status"] = 404
			errorHash["errormessage"] = "Found no resource types"
			respond_to do |f|
				f.json { render json: errorHash, :status => 404 }
				f.xml { render xml: errorHash, :status => 404 }
			end
		end
	end
	
	# GET: api/v1/resourcetype/:resourcetype?apikey=dsoumefehknkkxkumkkuzvmulclcdtkhcdwukbtg
	def show
		resourcetype = ResourceType.find_by_resource_type(params[:id])
		if resourcetype != nil
			resultHash = Hash.new
			resultArray = Array.new
			resourcetype.resources.each do |resource|
				resultArray << generateResourceHash(resource)
			end
			resultHash["status"]=200
			resultHash["resourcetype"]=generateResourceTypeHash(resourcetype)
			resultHash["resources"]=resultArray
			respond_to do |f|
				f.json { render json: resultHash, :status => 200 }
				f.xml { render xml: resultHash, :status => 200 }
			end
		else
			errorHash = Hash.new
			errorHash["status"] = 404
			errorHash["errormessage"] = "Found no such resource type"
			respond_to do |f|
				f.json { render json: errorHash, :status => 404 }
				f.xml { render xml: errorHash, :status => 404 }
			end
		end
	end
end
