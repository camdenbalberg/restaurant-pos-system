require 'net/http'
require 'uri'
require 'json'

class Api::V1::MenuItemsController < ApplicationController


  
      # GET /api/v1/menu_items
      # @description
      # Queries the database for all menu items or filters them by category if a `category` parameter is provided.
      # If the `category` parameter is not provided, all menu items are returned.
      # @returns [Array<MenuItem>] List of menu items in JSON format.
      def index
        if params[:category]
          menu_items = MenuItem.where(category: params[:category])
          render json: menu_items
        else
          render json: MenuItem.all
        end
      end

      # GET /api/v1/menu_items/:id
      # @description
      # Fetches a specific menu item by its ID.
      # If the menu item is found, it returns the item in JSON format.
      # If not found, it returns an error message with a `404 Not Found` status.
      # @param id [Integer] The unique identifier of the menu item.
      # @returns [MenuItem] The requested menu item in JSON format.
      # @raises ActiveRecord::RecordNotFound if menu item with given ID is not found.

      def show
        menu_items = MenuItem.find(params[:id])
        render json: menu_items
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Menu item not found' }, status: :not_found
      end

      # POST /api/v1/menu_items/add_menu_item
      # @description
      # Creates a new menu item with the provided `menu_name`, `price`, and `category`.
      # If any required parameters are missing, it returns an error.
      # @param menu_name [String] The name of the menu item.
      # @param price [Decimal] The price of the menu item.
      # @param category [String] The category the menu item belongs to.
      # @returns [MenuItem] The newly created menu item in JSON format.
      # @raises ActionController::ParameterMissing if required parameters are missing.
      def add_menu_item
        menu_name = params[:menu_name]
        price = params[:price]
        category = params[:category]

          # Check if all required parameters are present
        if menu_name.nil? || price.nil? || category.nil?
          render json: { error: 'Missing parameters: menuName, price, or category' }, status: :unprocessable_entity
          return
        end

        highest_menu_id = MenuItem.maximum(:menu_id) || 0  # Returns 0 if no menu_items exist
        Rails.logger.info "#{highest_menu_id}"
        new_menu_id = highest_menu_id + 1

        Rails.logger.info "Received parameters: menuName = #{menu_name}, price = #{price}, category = #{category}"
        # Create new MenuItem instance
        menu_item = MenuItem.new(menu_id: new_menu_id, menu_name: menu_name, price: price, category: category)
        if menu_item.save
          render json: menu_item, status: :created
        else
          render json: { error: 'Failed to create menu item' }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/menu_items/:menu_id
      # @description
      # Deletes the menu item with the specified `menu_id`.
      # Returns a success message if the item is deleted, or an error message if not found.
      # @param menu_id [Integer] The unique identifier of the menu item.
      # @returns [String] A success message in JSON format if the deletion is successful.
      # @raises ActiveRecord::RecordNotFound if menu item with the given ID does not exist.
      def destroy
        menu_item = MenuItem.find_by(menu_id: params[:menu_id])

        if menu_item.nil?
          render json: { error: 'Menu item not found' }, status: :not_found
        else
          menu_item.destroy
          render json: { message: 'Menu item successfully deleted' }, status: :ok
        end
      end

      # @description
      # Uploads an image to Imgur and returns the image URL if the upload is successful.
      # This method is used for updating the image of a menu item.
      # @param image [Tempfile] The image file to be uploaded to Imgur.
      # @returns [String, nil] The Imgur URL of the uploaded image or `nil` if the upload fails.
      def upload_image_to_imgur(image)
        client_id = ENV['IMGUR_CLIENT_ID']  # Fetch the client ID from the environment variable
        client_secret = ENV['IMGUR_CLIENT_SECRET']  # Fetch the client secret (if needed)
      
        uri = URI('https://api.imgur.com/3/image')
        request = Net::HTTP::Post.new(uri)
        request['Authorization'] = "Client-ID #{client_id}"
      
        # Read the image content from the tempfile and encode it in base64
        image_data = Base64.encode64(params[:image].read)
      
        # Pass the base64-encoded image data to Imgur
        request.set_form_data({ 'image' => image_data })
      
        # Make the request
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end
      
        # Parse and return the Imgur link if the request was successful
        if response.is_a?(Net::HTTPSuccess)
          JSON.parse(response.body)['data']['link']  # Return the image URL
        else
          Rails.logger.error "Imgur Upload Error: #{response.body}"
          nil
        end
      end

      
      # PATCH /api/v1/menu_items/:menu_id/update_image
      # @description
      # Updates the image of a specific menu item by its `menu_id`.
      # If an image is uploaded, it is sent to Imgur and the image URL is updated.
      # If an image URL is provided, it will be used directly.
      # @param menu_id [Integer] The unique identifier of the menu item to be updated.
      # @param image [Tempfile] The image file to be uploaded to Imgur.
      # @param image_url [String] A direct URL to the image to be associated with the menu item.
      # @returns [MenuItem] The updated menu item with the new image in JSON format.
      # @raises ActiveRecord::RecordNotFound if the menu item is not found.
      def update_image
        menu_item = MenuItem.find_by(menu_id: params[:menu_id])
        
        if menu_item.nil?
          render json: { error: 'Menu item not found' }, status: :not_found
          return
        end

        # If an image file is provided, upload it to Imgur
        if params[:image].present?
          puts "Image: #{params[:image]}"  # Log the image parameter to ensure it's present
          Rails.logger.info "Cleared here"
          begin
            imgur_link = upload_image_to_imgur(params[:image].tempfile)
          rescue => e
            Rails.logger.error "Image Upload Error: #{e.message}"
            render json: { error: 'An unexpected error occurred during image upload' }, status: :unprocessable_entity
            return
          end
          
          Rails.logger.info "Image Details: #{params[:image].inspect}"
          Rails.logger.info "Tempfile Path: #{params[:image].tempfile.path}" if params[:image].respond_to?(:tempfile)
          Rails.logger.info "Cleared here 1 "
          if imgur_link.nil?
            render json: { error: 'Failed to upload image to Imgur' }, status: :unprocessable_entity
            return
          end
          Rails.logger.info "Cleared here 2"
          menu_item.image_url = imgur_link
        elsif params[:image_url].present?
          # If an image URL is provided, use it directly
          menu_item.image_url = params[:image_url]
        else
          render json: { error: 'No image or image_url parameter provided' }, status: :unprocessable_entity
          return
        end

        # Save the updated menu item
        if menu_item.save
          render json: { message: 'Image updated successfully', menu_item: menu_item }, status: :ok
        else
          render json: { error: 'Failed to update image', details: menu_item.errors.full_messages }, status: :unprocessable_entity
        end
      end


    # PATCH /api/v1/menu_items/:id
    # @description
    # Updates the details (menu_name, price, category) of an existing menu item identified by `id`.
    # If the update is successful, returns the updated menu item.
    # @param id [Integer] The unique identifier of the menu item.
    # @param menu_name [String] The updated name of the menu item.
    # @param price [Decimal] The updated price of the menu item.
    # @param category [String] The updated category of the menu item.
    # @returns [MenuItem] The updated menu item in JSON format.
    # @raises ActiveRecord::RecordNotFound if the menu item is not found.
    def update
      @menu_item = MenuItem.find(params[:id])
      
      if @menu_item.update(menu_item_params)
        render json: @menu_item, status: :ok
      else
        render json: { error: 'Failed to update menu item' }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Menu item not found" }, status: :not_found
    end

    # @description
    # Strong parameters for updating menu items.
    # Ensures only permitted fields are allowed for update.
    # @returns [Hash] The permitted parameters for updating a menu item.
    def menu_item_params
      params.permit(:menu_name, :price, :category)
    end
end
