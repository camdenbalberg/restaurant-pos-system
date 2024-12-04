module Api
    module V1
      class ScreensController < ApplicationController
      # POST /api/v1/screens/lock
      # @description
      # Locks the specified screen type by saving the screen's passkey and lock status.
      # Validates the screen type and passkey, and locks the screen if the passkey is correct.
      # A passkey must be exactly 6 characters long.
      # @param screenType [String] The type of screen to lock (e.g., "dashboard", "settings").
      # @param passkey [String] A 6-character passkey to lock the screen.
      # @returns [Message] A message confirming the lock status or an error if validation fails.
      # @raises ActionController::ParameterMissing if required parameters are missing or invalid.
        def lock
            screen_params = params.require(:screen).permit(:screenType, :passkey)
            screen_type = screen_params[:screenType]
            passkey = screen_params[:passkey]
  
          if screen_type.blank? || passkey.blank? || passkey.length != 6
            return render json: { error: "This line of code Invalid screen type or passkey" }, status: :unprocessable_entity
          end
  
          # Store lock state in the database or cache
          lock = ScreenLock.find_or_initialize_by(screen_type: screen_type)
          lock.passkey = passkey
          lock.locked = true
  
          if lock.save
            render json: { message: "#{screen_type} locked successfully!" }, status: :ok
          else
            render json: { error: "Failed to lock the screen" }, status: :internal_server_error
          end
        end
  
        # POST /api/v1/screens/unlock
        # @description
        # Unlocks the specified screen by verifying the provided passkey.
        # If the passkey matches the stored passkey, the screen is unlocked.
        # @param screenType [String] The type of screen to unlock.
        # @param passkey [String] The passkey used to unlock the screen.
        # @returns [Message] A message confirming the unlock status or an error if validation fails.
        # @raises ActionController::ParameterMissing if the required parameters are missing.
        def unlock
            screen_params = params.require(:screen).permit(:screenType, :passkey)
            screen_type = screen_params[:screenType]
            passkey = screen_params[:passkey]
          
            lock = ScreenLock.find_by(screen_type: screen_type)
          
            if lock.nil? || !lock.locked
              return render json: { error: "Screen is not locked" }, status: :unprocessable_entity
            end
          
            if lock.passkey == passkey
                ScreenLock.transaction do
                    if lock.update(locked: false, passkey: "")
                      render json: { message: "#{screen_type} unlocked successfully!" }, status: :ok
                    else
                      render json: { error: lock.errors.full_messages }, status: :unprocessable_entity
                    end
                  end                             
            else
              render json: { error: "Incorrect passkey" }, status: :unauthorized
            end
        end
        
        # GET /api/v1/screens/status
        # @description
        # Retrieves the current lock status of the specified screen type.
        # Returns whether the screen is locked or unlocked along with the associated passkey if locked.
        # @param screen_type [String] The type of screen whose status is being checked.
        # @returns [Status] The lock status and passkey (if locked) of the specified screen.
        # @raises ActiveRecord::RecordNotFound if the screen type is not found.
        def status
            screen_type = params[:screen_type]
    
            # Find the screen lock entry by screen_type
            lock = ScreenLock.find_by(screen_type: screen_type)
    
            if lock.nil?
              return render json: { error: "Screen type not found" }, status: :not_found
            end
    
            # Return whether the screen is locked or unlocked
            render json: { screen_type: screen_type, locked: lock.locked, passkey: lock.passkey }, status: :ok
        end

        private
        
        # @description
        # A helper method to authenticate the manager (for securing sensitive operations).
        # Ensures that the current user is a manager before performing any actions.
        # @returns [Error] If not authorized, a 401 Unauthorized response is returned.
        def authenticate_manager!
          # Add authentication logic for managers, e.g., using Devise or custom tokens
          render json: { error: "Unauthorized" }, status: :unauthorized unless current_user&.manager?
        end
      end
    end
  end
  