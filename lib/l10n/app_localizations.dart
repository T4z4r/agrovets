import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AgroVet'**
  String get appName;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Please sign in to your account'**
  String get welcomeBack;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Please try again.'**
  String get connectionError;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @suppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers;

  /// No description provided for @sellers.
  ///
  /// In en, this message translates to:
  /// **'Sellers'**
  String get sellers;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @goodDay.
  ///
  /// In en, this message translates to:
  /// **'Good Day!'**
  String get goodDay;

  /// No description provided for @businessOverview.
  ///
  /// In en, this message translates to:
  /// **'Here\'s your business overview'**
  String get businessOverview;

  /// No description provided for @totalProducts.
  ///
  /// In en, this message translates to:
  /// **'Total Products'**
  String get totalProducts;

  /// No description provided for @todaySales.
  ///
  /// In en, this message translates to:
  /// **'Today Sales'**
  String get todaySales;

  /// No description provided for @totalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSales;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @stockValue.
  ///
  /// In en, this message translates to:
  /// **'Stock Value'**
  String get stockValue;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @newSale.
  ///
  /// In en, this message translates to:
  /// **'New Sale'**
  String get newSale;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @failedLoadDashboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to load dashboard'**
  String get failedLoadDashboard;

  /// No description provided for @supplierName.
  ///
  /// In en, this message translates to:
  /// **'Supplier Name'**
  String get supplierName;

  /// No description provided for @enterSupplierName.
  ///
  /// In en, this message translates to:
  /// **'Enter supplier name'**
  String get enterSupplierName;

  /// No description provided for @contactPerson.
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get contactPerson;

  /// No description provided for @enterContactPerson.
  ///
  /// In en, this message translates to:
  /// **'Enter contact person name'**
  String get enterContactPerson;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @enterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get enterEmailAddress;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @enterSupplierAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter supplier address'**
  String get enterSupplierAddress;

  /// No description provided for @supplierCreated.
  ///
  /// In en, this message translates to:
  /// **'Supplier created successfully!'**
  String get supplierCreated;

  /// No description provided for @supplierUpdated.
  ///
  /// In en, this message translates to:
  /// **'Supplier updated successfully!'**
  String get supplierUpdated;

  /// No description provided for @failedSaveSupplier.
  ///
  /// In en, this message translates to:
  /// **'Failed to save supplier'**
  String get failedSaveSupplier;

  /// No description provided for @deleteSupplier.
  ///
  /// In en, this message translates to:
  /// **'Delete Supplier'**
  String get deleteSupplier;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @viewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get viewReceipt;

  /// No description provided for @createSale.
  ///
  /// In en, this message translates to:
  /// **'Create Sale'**
  String get createSale;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @addSelected.
  ///
  /// In en, this message translates to:
  /// **'Add Selected'**
  String get addSelected;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @saleDate.
  ///
  /// In en, this message translates to:
  /// **'Sale Date'**
  String get saleDate;

  /// No description provided for @selectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select Product'**
  String get selectProduct;

  /// No description provided for @chooseProduct.
  ///
  /// In en, this message translates to:
  /// **'Choose a product'**
  String get chooseProduct;

  /// No description provided for @transactionType.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get transactionType;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get enterQuantity;

  /// No description provided for @supplierOptional.
  ///
  /// In en, this message translates to:
  /// **'Supplier (Optional)'**
  String get supplierOptional;

  /// No description provided for @selectSupplier.
  ///
  /// In en, this message translates to:
  /// **'Select supplier'**
  String get selectSupplier;

  /// No description provided for @transactionDate.
  ///
  /// In en, this message translates to:
  /// **'Transaction Date'**
  String get transactionDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @remarksOptional.
  ///
  /// In en, this message translates to:
  /// **'Remarks (Optional)'**
  String get remarksOptional;

  /// No description provided for @addNotes.
  ///
  /// In en, this message translates to:
  /// **'Add any additional notes'**
  String get addNotes;

  /// No description provided for @stockIn.
  ///
  /// In en, this message translates to:
  /// **'Stock In'**
  String get stockIn;

  /// No description provided for @stockOut.
  ///
  /// In en, this message translates to:
  /// **'Stock Out'**
  String get stockOut;

  /// No description provided for @damage.
  ///
  /// In en, this message translates to:
  /// **'Damage'**
  String get damage;

  /// No description provided for @returnText.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnText;

  /// No description provided for @stockTransactionSaved.
  ///
  /// In en, this message translates to:
  /// **'Stock transaction saved successfully!'**
  String get stockTransactionSaved;

  /// No description provided for @failedSaveStock.
  ///
  /// In en, this message translates to:
  /// **'Failed to save stock transaction'**
  String get failedSaveStock;

  /// No description provided for @createStockTransaction.
  ///
  /// In en, this message translates to:
  /// **'Create Stock Transaction'**
  String get createStockTransaction;

  /// No description provided for @sellerName.
  ///
  /// In en, this message translates to:
  /// **'Seller Name'**
  String get sellerName;

  /// No description provided for @enterSellerName.
  ///
  /// In en, this message translates to:
  /// **'Enter seller name'**
  String get enterSellerName;

  /// No description provided for @sellerCreated.
  ///
  /// In en, this message translates to:
  /// **'Seller created successfully!'**
  String get sellerCreated;

  /// No description provided for @sellerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Seller updated successfully!'**
  String get sellerUpdated;

  /// No description provided for @failedSaveSeller.
  ///
  /// In en, this message translates to:
  /// **'Failed to save seller'**
  String get failedSaveSeller;

  /// No description provided for @deleteSeller.
  ///
  /// In en, this message translates to:
  /// **'Delete Seller'**
  String get deleteSeller;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get accessDenied;

  /// No description provided for @noPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this page.'**
  String get noPermission;

  /// No description provided for @failedLoadProducts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load products'**
  String get failedLoadProducts;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeleted;

  /// No description provided for @failedDeleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete product'**
  String get failedDeleteProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @enterProductName.
  ///
  /// In en, this message translates to:
  /// **'Enter product name'**
  String get enterProductName;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @enterUnit.
  ///
  /// In en, this message translates to:
  /// **'e.g., kg, liters, pieces'**
  String get enterUnit;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @enterCategory.
  ///
  /// In en, this message translates to:
  /// **'e.g., Medicine, Feed, Equipment'**
  String get enterCategory;

  /// No description provided for @initialStock.
  ///
  /// In en, this message translates to:
  /// **'Initial Stock'**
  String get initialStock;

  /// No description provided for @enterStockQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter stock quantity'**
  String get enterStockQuantity;

  /// No description provided for @costPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost Price (Tsh)'**
  String get costPrice;

  /// No description provided for @enterCostPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter cost price'**
  String get enterCostPrice;

  /// No description provided for @sellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling Price (Tsh)'**
  String get sellingPrice;

  /// No description provided for @enterSellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter selling price'**
  String get enterSellingPrice;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense Category'**
  String get expenseCategory;

  /// No description provided for @enterExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'e.g., Utilities, Supplies, Maintenance'**
  String get enterExpenseCategory;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount (Tsh)'**
  String get amount;

  /// No description provided for @enterExpenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter expense amount'**
  String get enterExpenseAmount;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @enterExpenseDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter expense description'**
  String get enterExpenseDescription;

  /// No description provided for @expenseDate.
  ///
  /// In en, this message translates to:
  /// **'Expense Date'**
  String get expenseDate;

  /// No description provided for @expenseCreated.
  ///
  /// In en, this message translates to:
  /// **'Expense created successfully!'**
  String get expenseCreated;

  /// No description provided for @expenseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Expense updated successfully!'**
  String get expenseUpdated;

  /// No description provided for @failedSaveExpense.
  ///
  /// In en, this message translates to:
  /// **'Failed to save expense'**
  String get failedSaveExpense;

  /// No description provided for @deleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpense;

  /// No description provided for @profitReport.
  ///
  /// In en, this message translates to:
  /// **'Profit Report'**
  String get profitReport;

  /// No description provided for @generatingReport.
  ///
  /// In en, this message translates to:
  /// **'Generating report...'**
  String get generatingReport;

  /// No description provided for @failedLoadProfitReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profit report'**
  String get failedLoadProfitReport;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
  String get selectStartDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @selectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select end date'**
  String get selectEndDate;

  /// No description provided for @dailyReport.
  ///
  /// In en, this message translates to:
  /// **'Daily Report'**
  String get dailyReport;

  /// No description provided for @generatingDailyReport.
  ///
  /// In en, this message translates to:
  /// **'Generating daily report...'**
  String get generatingDailyReport;

  /// No description provided for @failedLoadDailyReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to load daily report'**
  String get failedLoadDailyReport;

  /// No description provided for @reportDate.
  ///
  /// In en, this message translates to:
  /// **'Report Date'**
  String get reportDate;

  /// No description provided for @selectReportDate.
  ///
  /// In en, this message translates to:
  /// **'Select date for report'**
  String get selectReportDate;

  /// No description provided for @stockTransactions.
  ///
  /// In en, this message translates to:
  /// **'Stock Transactions'**
  String get stockTransactions;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @totalSalesLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSalesLabel;

  /// No description provided for @totalExpensesLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpensesLabel;

  /// No description provided for @netProfit.
  ///
  /// In en, this message translates to:
  /// **'Net Profit'**
  String get netProfit;

  /// No description provided for @failedLoadReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to load report'**
  String get failedLoadReport;

  /// No description provided for @agroVetSeller.
  ///
  /// In en, this message translates to:
  /// **'AgroVet Seller'**
  String get agroVetSeller;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'sw': return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
