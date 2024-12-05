# Sessions Controller

## Methods

<!-- @vuese:ApplicationController:methods:start -->
|Method|Description|Parameters|
|---|---|---|
|authenticate_user|Authenticates the current user based on the JWT token stored in cookies.|-|
|current_user|Retrieves the currently authenticated user from the decoded JWT token.|-|
|not_authorized|Handles unauthorized access by returning an appropriate JSON error response.|-|
|force_session|Ensures the session data is persisted by adding a custom session key.|-|
<!-- @vuese:ApplicationController:methods:end -->
