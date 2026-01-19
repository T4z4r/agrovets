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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
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

  /// No description provided for @lowStockProducts.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Products'**
  String get lowStockProducts;

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

  /// No description provided for @failedLoadSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Failed to load suppliers'**
  String get failedLoadSuppliers;

  /// No description provided for @failedLoadStock.
  ///
  /// In en, this message translates to:
  /// **'Failed to load stock transactions'**
  String get failedLoadStock;

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

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @noProductsMatch.
  ///
  /// In en, this message translates to:
  /// **'No products match your search'**
  String get noProductsMatch;

  /// No description provided for @stockLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stockLabel;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @deleteProductConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get deleteProductConfirm;

  /// No description provided for @productDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeletedSuccess;

  /// No description provided for @searchSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Search suppliers...'**
  String get searchSuppliers;

  /// No description provided for @noSuppliersFound.
  ///
  /// In en, this message translates to:
  /// **'No suppliers found'**
  String get noSuppliersFound;

  /// No description provided for @noSuppliersMatch.
  ///
  /// In en, this message translates to:
  /// **'No suppliers match your search'**
  String get noSuppliersMatch;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get searchTransactions;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No stock transactions found'**
  String get noTransactionsFound;

  /// No description provided for @noTransactionsMatch.
  ///
  /// In en, this message translates to:
  /// **'No transactions match your search'**
  String get noTransactionsMatch;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @searchSales.
  ///
  /// In en, this message translates to:
  /// **'Search sales...'**
  String get searchSales;

  /// No description provided for @noSalesFound.
  ///
  /// In en, this message translates to:
  /// **'No sales found'**
  String get noSalesFound;

  /// No description provided for @noSalesMatch.
  ///
  /// In en, this message translates to:
  /// **'No sales match your search'**
  String get noSalesMatch;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @searchExpenses.
  ///
  /// In en, this message translates to:
  /// **'Search expenses...'**
  String get searchExpenses;

  /// No description provided for @noExpensesFound.
  ///
  /// In en, this message translates to:
  /// **'No expenses found'**
  String get noExpensesFound;

  /// No description provided for @noExpensesMatch.
  ///
  /// In en, this message translates to:
  /// **'No expenses match your search'**
  String get noExpensesMatch;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @searchSellers.
  ///
  /// In en, this message translates to:
  /// **'Search sellers...'**
  String get searchSellers;

  /// No description provided for @noSellersFound.
  ///
  /// In en, this message translates to:
  /// **'No sellers found'**
  String get noSellersFound;

  /// No description provided for @noSellersMatch.
  ///
  /// In en, this message translates to:
  /// **'No sellers match your search'**
  String get noSellersMatch;

  /// No description provided for @saleLabel.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get saleLabel;

  /// No description provided for @itemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsLabel;

  /// No description provided for @stockTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock Transaction'**
  String get stockTransactionTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @saveTransaction.
  ///
  /// In en, this message translates to:
  /// **'Save Transaction'**
  String get saveTransaction;

  /// No description provided for @createExpense.
  ///
  /// In en, this message translates to:
  /// **'Create Expense'**
  String get createExpense;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @addNewExpense.
  ///
  /// In en, this message translates to:
  /// **'Add New Expense'**
  String get addNewExpense;

  /// No description provided for @editExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpenseTitle;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Category is required'**
  String get categoryRequired;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get amountRequired;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @createProduct.
  ///
  /// In en, this message translates to:
  /// **'Create Product'**
  String get createProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @addNewProduct.
  ///
  /// In en, this message translates to:
  /// **'Add New Product'**
  String get addNewProduct;

  /// No description provided for @minimumQuantity.
  ///
  /// In en, this message translates to:
  /// **'Minimum Quantity'**
  String get minimumQuantity;

  /// No description provided for @enterMinimumQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter minimum quantity'**
  String get enterMinimumQuantity;

  /// No description provided for @minimumQuantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Minimum quantity is required'**
  String get minimumQuantityRequired;

  /// No description provided for @updateProduct.
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get updateProduct;

  /// No description provided for @prices.
  ///
  /// In en, this message translates to:
  /// **'Prices'**
  String get prices;

  /// No description provided for @timestamps.
  ///
  /// In en, this message translates to:
  /// **'Timestamps'**
  String get timestamps;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @remarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get remarks;

  /// No description provided for @recordedBy.
  ///
  /// In en, this message translates to:
  /// **'Recorded by'**
  String get recordedBy;

  /// No description provided for @createSupplier.
  ///
  /// In en, this message translates to:
  /// **'Create Supplier'**
  String get createSupplier;

  /// No description provided for @editSupplier.
  ///
  /// In en, this message translates to:
  /// **'Edit Supplier'**
  String get editSupplier;

  /// No description provided for @addNewSupplier.
  ///
  /// In en, this message translates to:
  /// **'Add New Supplier'**
  String get addNewSupplier;

  /// No description provided for @updateSupplier.
  ///
  /// In en, this message translates to:
  /// **'Update Supplier'**
  String get updateSupplier;

  /// No description provided for @supplierNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Supplier name is required'**
  String get supplierNameRequired;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get blocked;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @createSeller.
  ///
  /// In en, this message translates to:
  /// **'Create Seller'**
  String get createSeller;

  /// No description provided for @editSeller.
  ///
  /// In en, this message translates to:
  /// **'Edit Seller'**
  String get editSeller;

  /// No description provided for @addNewSeller.
  ///
  /// In en, this message translates to:
  /// **'Add New Seller'**
  String get addNewSeller;

  /// No description provided for @updateSeller.
  ///
  /// In en, this message translates to:
  /// **'Update Seller'**
  String get updateSeller;

  /// No description provided for @newPasswordOptional.
  ///
  /// In en, this message translates to:
  /// **'New Password (optional)'**
  String get newPasswordOptional;

  /// No description provided for @leaveEmptyKeepCurrent.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to keep current'**
  String get leaveEmptyKeepCurrent;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @enterConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get enterConfirmPassword;

  /// No description provided for @leaveEmptyNotChanging.
  ///
  /// In en, this message translates to:
  /// **'Leave empty if not changing'**
  String get leaveEmptyNotChanging;

  /// No description provided for @passwordConfirmationRequired.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation is required'**
  String get passwordConfirmationRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @stockTransaction.
  ///
  /// In en, this message translates to:
  /// **'Stock Transaction'**
  String get stockTransaction;

  /// No description provided for @productRequired.
  ///
  /// In en, this message translates to:
  /// **'Product is required'**
  String get productRequired;

  /// No description provided for @quantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity is required'**
  String get quantityRequired;

  /// No description provided for @saleDetails.
  ///
  /// In en, this message translates to:
  /// **'Sale Details'**
  String get saleDetails;

  /// No description provided for @saleItems.
  ///
  /// In en, this message translates to:
  /// **'Sale Items'**
  String get saleItems;

  /// No description provided for @noItemsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No items added yet'**
  String get noItemsAddedYet;

  /// No description provided for @selectProducts.
  ///
  /// In en, this message translates to:
  /// **'Select Products'**
  String get selectProducts;
  String get sale;
  String get items;
  String get updateExpense;
  String get netIncome;
  String get netLoss;
  String get selectDateToGenerateDailyReport;
  String get sellerNameRequired;
  String get success;
  String get productCreated;
  String get productUpdated;
  String get productNameRequired;
  String get unitRequired;
  String get stockRequired;
  String get enterValidNumber;
  String get costPriceRequired;
  String get sellingPriceRequired;
  String get cameraPermissionRequired;
  String get cameraPermissionPermanentlyDenied;
  String get ok;
  String get barcode;
  String get scanBarcode;
  String get outOfStock;
  String get scan;
  String get selected;
  String get productNotFoundForBarcode;
  String get errorFindingProduct;
  String get increasedQuantityOf;
  String get addedToSale;
  String get saleSavedSuccessfully;
  String get insufficientStockFor;
  String get available;
  String get totalAmount;
  String get saleSaved;
  String get deleteSale;
  String get deleteSaleConfirm;
  String get saleDeletedSuccessfully;
  String get failedDeleteSale;
  String get productDetails;
  String get failedLoadProduct;
  String get productNotFound;
  String get stockInformation;
  String get currentStock;
  String get pricingInformation;
  String get additionalInformation;
  String get confirmLanguageChange;
  String get languageChangeMessage;
  String get operationFailed;
  String get registrationFailed;
  String get createAccount;
  String get fullName;
  String get enterFullName;
  String get nameRequired;
  String get shopName;
  String get enterShopName;
  String get shopNameRequired;
  String get shopLocation;
  String get enterShopLocation;
  String get shopLocationRequired;
  String get confirmPasswordRequired;
  String get signUp;
  String get alreadyHaveAccount;
  String get otpVerification;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms and Conditions and Privacy Policy'**
  String get agreeToTerms;

  /// No description provided for @termsAndPolicy.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions and Privacy Policy'**
  String get termsAndPolicy;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @acceptTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms and conditions to continue'**
  String get acceptTermsRequired;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we'll send you a password reset OTP.'**
  String get forgotPasswordDescription;

  /// No description provided for @sendResetOtp.
  ///
  /// In en, this message translates to:
  /// **'Send Reset OTP'**
  String get sendResetOtp;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP sent to {email} and your new password.'**
  String resetPasswordDescription(String email);

  /// No description provided for @otpCode.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get otpCode;

  /// No description provided for @enterOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get enterOtpCode;

  /// No description provided for @otpRequired.
  ///
  /// In en, this message translates to:
  /// **'OTP is required'**
  String get otpRequired;

  /// No description provided for @otpMustBe6Digits.
  ///
  /// In en, this message translates to:
  /// **'OTP must be 6 digits'**
  String get otpMustBe6Digits;

  /// No description provided for @otpMustBeDigits.
  ///
  /// In en, this message translates to:
  /// **'OTP must contain only digits'**
  String get otpMustBeDigits;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully. Please login with your new password.'**
  String get passwordResetSuccess;

  /// No description provided for @passwordResetOtpSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset OTP sent to your email.'**
  String get passwordResetOtpSent;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @otpAlreadySent.
  ///
  /// In en, this message translates to:
  /// **'OTP already sent. Please wait before requesting a new one.'**
  String get otpAlreadySent;

  /// No description provided for @invalidOrExpiredOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired OTP'**
  String get invalidOrExpiredOtp;

  /// No description provided for @failedToSendResetOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to send password reset OTP'**
  String get failedToSendResetOtp;

  /// No description provided for @failedToResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password'**
  String get failedToResetPassword;

  /// No description provided for @shopDetails.
  ///
  /// In en, this message translates to:
  /// **'Shop Details'**
  String get shopDetails;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
