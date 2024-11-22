module Api
    module V1
      class ScreensController < ApplicationController
        # Lock screen
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
  
        # Unlock screen
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
  
        def authenticate_manager!
          # Add authentication logic for managers, e.g., using Devise or custom tokens
          render json: { error: "Unauthorized" }, status: :unauthorized unless current_user&.manager?
        end
      end
    end
  end
  