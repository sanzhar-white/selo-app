class ErrorMessages {
  static const String failedToInitApp = 'Error during initialization';

  static const String failedToLoadAdvertisements =
      'Failed to load advertisements';
  static const String failedToViewAdvert = 'Failed to view advert';
  static const String failedToLoadFilteredAds = 'Failed to load filtered ads';
  static const String failedToLoadBanners = 'Failed to load banners';
  static const String errorClearingFilteredAds = 'Error clearing filtered ads';
  static const String errorClearingCacheFilteredAds =
      'Error clearing filtered ads cache';
  static const String failedToClearFilteredAds = 'Failed to clear filtered ads';
  static const String showingErrorToUser = 'Showing error to user';
  static const String imageLoadError = 'Image load error';
  static const String failedToIncrementViewCount =
      'Failed to increment view count';
  static const String failedToParseAdvertisement =
      'Failed to parse advertisement';
  static const String invalidDataTypeForAdvertisement =
      'Invalid data type for advertisement';
  static const String firestoreIndexRequired =
      'Firestore index required. Please create the index in the Firebase Console.';
  static const String failedToFetchFilteredAdvertisements =
      'Failed to fetch filtered advertisements';
  static const String failedToFetchAdvertisements =
      'Failed to fetch advertisements';
  static const String failedToFetchBanners = 'Failed to fetch banners';
  static const String errorInToggleFavourite = 'Error in toggleFavourite';
  static const String userDataIsNullForUser = 'User data is null for user';
  static const String userDataIsNull = 'User data is null';
  static const String userNotFound = 'User not found';
  static const String errorInRemoveFromFavourites =
      'Error in removeFromFavourites';
  static const String errorInAddToFavourites = 'Error in addToFavourites';
  static const String errorInGetFavourites = 'Error in getFavourites';
  static const String errorInCheckUser = 'Error in checkUser';
  static const String exceptionInCheckUser = 'Exception in checkUser';
  static const String userDoesNotExist = 'User does not exist';
  static const String loginFailed = 'Login failed';
  static const String nameIsEmpty = 'Name is empty';
  static const String invalidPhoneNumberFormat = 'Invalid phone number format';
  static const String signupFailed = 'Signup failed';
  static const String exceptionInSignup = 'Exception in signup';
  static const String failedToFetchAdverts = 'Failed to fetch adverts';
  static const String failedToDeleteAdvert = 'Failed to delete advert';
  static const String failedToDeleteUser = 'Failed to delete user';
  static const String failedToUpdateUser = 'Failed to update user';
  static const String imageFileNotExist = 'Image file does not exist';
  static const String imageTooLarge = 'Image file is too large';
  static const String failedToUploadImage = 'Failed to upload profile image';
  static const String failedToLoadAdverts = 'Failed to load my adverts';
  static const String unknownError = 'Unknown error occurred';

  static const String phoneNumberAlreadyRegistered =
      'Phone number already registered';
  static const String autoVerificationTimeout = 'Auto-verification timeout';
  static const String phoneNumberMustStartWithPlus =
      'Phone number must start with +';
  static const String phoneNumberNotRegistered =
      'Phone number is not registered';
  static const String failedToParseUserData = 'Failed to parse user data';
  static const String failedToCreateAnonymousUser =
      'Failed to create anonymous user';
  static const String invalidVerificationId = 'Invalid verification ID';
  static const String invalidSmsCodeFormat = 'Invalid SMS code format';
  static const String authenticationFailedNoUser =
      'Authentication failed - no user returned';
  static const String authenticationFailed = 'Authentication failed';

  static const String autoVerificationSignInError =
      'Auto-verification sign-in error';
  static const String verificationFailed = 'Verification failed';
  static const String signUpError = 'SignUp error';
  static const String checkUserError = 'Check user error';
  static const String userNotFoundInFirestore = 'User not found in Firestore';
  static const String autoSignInFailedNoUserReturned =
      'Auto-sign in failed - no user returned';
  static const String autoSignInError = 'Auto-sign in error';
  static const String phoneVerificationError = 'Phone verification error';
  static const String loginProcessError = 'Login process error';
  static const String failedToReuseAnonymousAccount =
      'Failed to reuse anonymous account';
  static const String anonymousLoginError = 'Anonymous login error';
  static const String emptyVerificationId = 'Empty verification ID';
  static const String invalidSmsCodeLength = 'Invalid SMS code length';
  static const String noUserReturnedAfterSignIn =
      'No user returned after sign in';
  static const String signInWithCredentialError =
      'Sign in with credential error';
  static const String logoutError = 'Logout error';

  static const String fileDoesNotExist = 'File does not exist';
  static const String firebaseErrorDuringUpload =
      'Firebase error during upload';
  static const String errorUploadingSingleImage =
      'Error uploading single image';
  static const String failedToUploadImageAfterRetries =
      'Failed to upload image after retries';
  static const String failedToUploadAnyImages =
      'Failed to upload any images after retries';
  static const String errorInUploadImages = 'Error in _uploadImages';
  static const String failedToUploadImagesNoSuccess =
      'Failed to upload images - no successful uploads';
  static const String errorUploadingImages = 'Error uploading images';
  static const String errorInCreateAd = 'Error in createAd';
  static const String errorParsingCategory = 'Error parsing category document';
  static const String errorInGetCategories = 'Error in getCategories';

  static const String errorInitializingLocalStorage =
      'Error initializing LocalStorageService';
  static const String errorSavingUser = 'Error saving user';
  static const String errorGettingUser = 'Error getting user';
  static const String errorDeletingUser = 'Error deleting user';
  static const String errorCheckingUserLoginStatus =
      'Error checking user login status';
  static const String errorClearingAllData = 'Error clearing all data';
  static const String errorCachingBanners = 'Error caching banners';
  static const String errorGettingCachedBanners =
      'Error getting cached banners';
  static const String errorCachingAdvertisements =
      'Error caching advertisements';
  static const String errorDeserializingAdvert = 'Error deserializing advert';
  static const String errorGettingCachedAds = 'Error getting cached ads';
  static const String errorClearingAdsCache = 'Error clearing ads cache';
  static const String errorCachingFilteredAds = 'Error caching filtered ads';
  static const String errorDeserializingFilteredAdvert =
      'Error deserializing filtered advert';
  static const String errorGettingCachedFilteredAds =
      'Error getting cached filtered ads';

  static const String invalidOrNoSavedLocale =
      'Invalid or no saved locale, defaulting to en';
  static const String errorLoadingLocale = 'Error loading locale';
  static const String unsupportedLocale = 'Unsupported locale';
  static const String errorSavingLocale = 'Error saving locale';
  static const String formValidationFailed = 'Form validation failed';
  static const String failedToCreateAdvert = 'Failed to create advert';
  static const String errorCreatingAdvert = 'Error creating advert';
  static const String tooManyImages = 'User tried to add more than 10 images';
  static const String selectedImageNotFound = 'Selected image file not found';
  static const String imageSizeTooLarge = 'Image size too large';
  static const String errorSelectingImage = 'Error selecting image';
  static const String cannotVerifyOTP = 'Cannot verify OTP';
  static const String noVerificationCodeEntered =
      'No verification code entered';
  static const String otpVerificationFailedSuccessFalse =
      'OTP verification failed: success was false';
  static const String otpVerificationFailedWithError =
      'OTP verification failed with error';
  static const String exceptionInOtpVerification =
      'Exception in OTP verification';
  static const String errorInUseCase = 'Error in use case';
  static const String errorInAnonymousLogIn = 'Error in anonymousLogIn';
  static const String failedToGetUserData = 'Failed to get user data';
  static const String errorInCheckUserPhonePage = 'Error in checkUser';
  static const String exceptionInCheckUserPhonePage = 'Exception in checkUser';
  static const String loginFailedPhonePage = 'Login failed';
  static const String exceptionInLoginPhonePage = 'Exception in login';
  static const String signupFailedPhonePage = 'Signup failed';
  static const String exceptionInSignupPhonePage = 'Exception in signup';
  static const String advertAlreadyInFavourites = 'Advert already in favourites';
  static const String advertNotInFavourites = 'Advert not in favourites';
}
