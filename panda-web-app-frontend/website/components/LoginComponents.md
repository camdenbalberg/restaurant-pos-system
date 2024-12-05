# LoginComponents

## Methods

<!-- @vuese:LoginComponents:methods:start -->
|Method|Description|Parameters|
|---|---|---|
|googleLogin|Initiates the Google login flow by redirecting to Google OAuth. Changes the button state briefly for a visual effect.|-|
|submitForm|Normal login without using Google OAuth. Navigates to the home screen on success and not if there is an error or invalid credentials.|-|
|skipForm|Allows to skip login process (for development use)|-|

<!-- @vuese:LoginComponents:methods:end -->


## Data

<!-- @vuese:LoginComponents:data:start -->
|Name|Type|Description|Default|
|---|---|---|---|
|username|`String`|The username entered by the user. type: {String}|-|

<!-- @vuese:LoginComponents:data:end -->


