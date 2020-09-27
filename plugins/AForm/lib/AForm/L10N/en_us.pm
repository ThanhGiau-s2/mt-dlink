# A plugin for manage multifunctiona cntact form.
# Copyright (c) ARK-Web Co.,Ltd.

package AForm::L10N::en_us;

use strict;
use base qw( AForm::L10N );
use vars qw( %Lexicon );

## The following is the translation table.

%Lexicon = (
    '_PLUGIN_DESCRIPTION' => 'This plugin adds functions of inquiry form, form management and inquiry data downloading, etc...',
    '_PLUGIN_AUTHOR' => 'ARK-Web\'s MT Plugin Developers',
    'AForm' => 'AForm',
    'AForms' => 'AForms',

    'AForm Field Types' => 'Basic Parts',
    'AForm Field Type Label' => 'Label',
    'AForm Field Type Text' => 'Text',
    'AForm Field Type Textarea' => 'Textarea',
    'AForm Field Type Select' => 'Select',
    'AForm Field Type Checkbox' => 'Checkbox',
    'AForm Field Type Radio' => 'Radio',

    'AForm Field Extra Types' => 'Custom Parts',
    'AForm Field Extra Type Email' => 'Email',
    'AForm Field Extra Type Telephone' => 'Telephone',
    'AForm Field Extra Type URL' => 'URL',
    'icon_new_windows' => '',
    'year' => ' / ',
    'month' => ' / ',
    'day' => ' (yyyy/mm/dd) ',
    'Alert Report Setting' => 'Form Operation Report Setting',

# plugin setting
    'Alert Report Setting' => 'Form Operation Report Setting',

    'Report by access to some form Title' => 'Start reporting by access to any form',
    'Report by access to some form Description' => "Start reporting by visitor's access to any form, when not have been running reporting a certain period of time or longer. If your server can not use cron jobs, you should use this. If reporting interval is not set, runs on 24h interval.",
    'Report by access to some form' => 'Start reporting by access to any form',
    'Interval of check(ex: 30min, 24h, 3day)' => 'Interval of check (eg. 30min, 24h, 3day)',

    'Alert mail address Title' => 'Reporting mail address',
    'Alert mail address Description' => 'Input the mail address you want to recieve reporting mail.',
    'Alert mail address' => 'Reporting mail address',

    'Alert confirm pv Title' => 'Minimum access to confirm page',
    'Alert confirm pv Description' => 'If access to confirm page is lesser than specified number of times, reporting mail will be sent. If blank, will be regarded as specifing 1.',
    'Alert confirm pv' => 'Minimum access to confirmation page',
    'Alert Data count Title' => 'Minimum number of contact data',
    'Alert Data count Description' => 'If number of contact data is lesser than specified number, reporting mail will be sent. If blank, will be regarded as specifing 1.',
    'Alert Data count' => 'Minimum number of contact data',

    'Script URL Directory Title' => 'Script URL Directory',
    'Script URL Directory Description' => "To change the form program's directory, please enter the url. It should be same server, and can run cgi program.<br />
eg. https://example.jp/cgi-bin/mt/plugins/AForm/",
    'Script URL Directory' => 'Script URL Directory',

    'Upload Setting' => 'File Upload Setting',
    'Upload Directory Title' => 'File Upload Directory',
    'Upload Directory Description' => 'Please enter the directory when user upload the file using file upload function. Absolute path is recommended, but you can enter relative path from Movable Type directory. If value is blank, it will be "(Movable Type Directory)/plugins/AForm/data/".',
    'Upload Directory' => 'File Upload Directory',

    'SerialNumber Setting' => 'Serial Number Setting',
    'SerialNumber: ' => 'Serial Number: ',
    'Invalid SerialNumber' => 'Serial Number is Invalid',
    'SerialNumber Title for Business' => 'Serial Number',
    'SerialNumber Description for Business' => 'Please enter the serial number.  If you have not purchased, you can buy at <a href="https://www.ark-web.jp/movabletype/a-form/price.html">A-Form purchase form</a>.', 
    'SerialNumber Title for Personal' => 'Serial Number',
    'SerialNumber Description for Personal' => 'If you don\'t want to dispray "Powered by A-Form for Movable Type", prease purchase the lisence and enter the serial number. You can buy at <a href="https://www.ark-web.jp/movabletype/a-form/price.html">A-Form purchase form</a>.',

# list_aform
    'No A-Form could be found.' => 'No form could be found.',
    '_PLUGIN_DESCRIPTION' => "This plugin's functionnality is to make various contact forms, manage contact data, check the conversion rate, etc.",
    '_PLUGIN_AUTHOR' => 'ARK-Web co., ltd.',
    'AForm' => 'A-Form',
    'AForms' => 'A-Form',
    'aform' => 'A-Form',
    'aforms' => 'A-Form',
    'aform_field' => 'Form Field',
    'Edit AForm' => 'Edit Form',
    'Create AForm' => 'Create New Form',
    'Manage A-Form' => 'Manage Form',
    'All A-Form' => 'All Form',
    'Are you sure you want to Delete the selected A-Form?' => 'Are you sure you want to delete the form?',
    'conversion rate description' => 'Conversion rate = action/page view',
    'how to build A-Form' => 'To embed the form, please write "[_1] (three digits surrounded by parenthesis)" in blog article or web page that you want to embed the form.', 
    'how to build A-Form blog warning' => '<div id="form-permisson" class="msg msg-info first-child">
<p class="first-child"><strong>
The form you created here will be used only in this blog.</strong><br />
So if you want to use it in multi web site or blogs, please go to system menu, then create the form.
</p>
</div>',
    'how to build A-Form system warning' => '<div id="form-permisson" class="msg msg-info first-child">
<p class="first-child"><strong>
The form you created here will be used in in multi web sites or blogs.</strong><br />
If you want to create the form only for specific blog. please go to that blog, then create the form.
</p>
</div>',

# edit_aform_field
    'List A-Form Input Error' => 'Error Report',

    'AForm Field Types' => 'Basic Field Parts',
    'AForm Field Type Label' => 'Label',
    'AForm Field Type Note' => 'Note',
    'AForm Field Type Text' => 'Text',
    'AForm Field Type Textarea' => 'Text area',
    'AForm Field Type Select' => 'Drop dowm',
    'AForm Field Type Checkbox' => 'Check box',
    'AForm Field Type Radio' => 'Radio Button',
    'AForm Field Type Upload' => 'File upload',
    'AForm Field Type Parameter' => 'External parameter ',

    'AForm Field Extra Types' => 'Extra Field Parts',
    'AForm Field Extra Type Email' => 'e-mail',
    'AForm Field Extra Type Telephone' => 'Telephone',
    'AForm Field Extra Type URL' => 'URL',
    'AForm Field Extra Type ZipCode' => 'Zip code',
    'AForm Field Extra Type Prefecture' => 'Prefecture',
    'AForm Field Extra Type Privacy' => 'Privacy policy',

    'tip_email' => 'Check if valid e-mail address format',
    'tip_tel' => 'Allow numbers and hyphen only',
    'tip_url' => 'Check if valid URL format',
    'tip_zipcode' => 'Allow 3 + 4 dights numbers and hyphen only',
    'tip_prefecture' => 'Allow to choose Prefecture by drop down',
    'tip_privacy' => 'You can set link to Privacy policy page and plase agree check box',

    'necessary' => 'Required',
    'not necessary' => 'Optional',
    'necessary description' => "You can toggle Required / Optional by click, If you set to Required, It shows error when user input nothing.",
    'input example is not displayed' => 'Do not display the input example',
    'undefined max length' => 'Undefine max length',
    'delete default' => 'Delete default phrase',
    'use default' => 'Add default phrase',
    'ZipCode' => 'Zip code',
    'Privacy' => 'Privacy policy',
    'privacy_link' => 'Link to Privacy policy page',
    'privacy policy warning' => 'It is not recommended to set the check box on to agree to Privacy policy.',
    'Upload Type:' => 'Upload file type:',
    'undefined upload type' => 'Allow all type',
    'edit upload type' => 'Edit upload file type',
    'upload file type description' => 'Please enter the extensions you want to allow. Extract period(.), and separate with comma(,) when you want to allow multi extensions. (eg. pdf,jpg,png)',
    'Upload Size:' => 'Maximum upload file size:',
    'undefined upload size' => 'Allow any file size',
    'edit upload size' => 'Edit upload file size',
    'Bytes' => 'Bytes or less',
    'upload file size description' => 'Please enter maximum upload file size. eg. 1Kb=1000, 1Mb=1000000',
    'check status is reflected in default check status of form.' => 'If you check here, the value will be reflect to actual form.',
    'Your changes has not saved! Are you ok?' => 'Your Setting is not saved yet. Are you ok?',
    'alert disable tab' => "Please save after enter the form name. If you do not save, you can not do anything with the form.",
    'Please rebuild blog which has some AForm.' => 'To apply change to the form, please rebuild the blog',
    'description when there is no field' => "To add the field parts, just click the parts or drag it to here. To change the parts' display order, drag and drop the parts or click the arrow icon in the parts.",
    'is replyed to customer' => 'Send duplicate mail to this address',
    'Status is published. Cannot edit fields.' => 'To protect contact data, please change form status to Unpublished before edit the form.',
    'Publish this A-Form.' => 'Publish the form.',
    'Unpublish this A-Form.' => 'Publish the form.',
    'Status was changed Published.' => 'Status changed to Published.',
    'Status was changed Unpublished.' => 'Status changed to Unpublished.',
    'Currently, This form status is Unpublished.' => 'Form status is Unpublished.',
    'Form data exists. Please download and clear data first.' => 'Contact data of the form exists. Please download and clear data first before edit the form.',
    'You have successfully deleted the Form data(s).' => 'You have successfully deleted the form contact data.',
    'Delete upload parts warning' => 'If you delete the parts, you will lose the data you get by this parts',
    'Characters' => 'Characters or less',

# edit_aform
    'Title Setting' => 'Form Title Setting',
    'Title' => 'Form Title',
    'Thanks page Setting' => 'Thank you page Setting',
    'Enter URL or Select Web Page.' => 'Please select the action when sending of the form is completed',
    'ThanksURL' => 'Redirect to the URL',
    'Select Page' => 'Redirect to the page',
    'Form Status' => 'Form status',
    'Enable' => 'Publish',
    'Disable' => 'Unpublish (This setting is prior to all other settings such as Publishing period)
',
    'Form Schedule' => 'Publication period',
    'Schedule Start Date' => 'Publication start date',
    'Schedule End Date' => 'Publication end date',
    'Schedule Start Time' => 'Publication start time',
    'Schedule End Time' => 'Publication end time',
    'Schedule Start Time description' => 'eg. 18:05:00',
    'Schedule End Time description' => 'eg. 23:59:59',
    'Receive limit' => 'Maximum Application Number',
    'msg before start' => 'Message before publication start',
    'description before start' => 'Before form publication period start, the message you define will appear on the form. eg. "Registration starts on January 1."',
    'msg limit over' => 'Message reaching maximum acceptable number',
    'description limit over' => 'After number of acceptance reaching to maximum, form will be unpublished, then appear the message you define. But after publication end date (if you set the date), the message after publication end is displayed by priority. eg. "It has ended the reception because it reached a capacity."',
    'msg after end' => 'Message after publication end',
    'description after end' => 'After form publication period end, the message you define will appear on the form. eg. "Registration ended on January 1.',
    'Mail From' => 'From: (Administrator address)',
    'Admin Mail To' => 'To: (Administrator address)',
    'Customers Mail To' => 'To:',
    'Mail CC' => 'CC:',
    'Mail BCC' => 'BCC:',
    'Replyed to Customer' => 'Send duplicate mail to sender',
    'New A-Form' => 'New form',
    'label_thanks_url_default' => 'Display send complete message on confirm page',
    'label_thanks_url_finish' => 'Display thank you page',
    'label_thanks_url_select' => 'Redirect to specific page',
    'label_thanks_url' => 'Redirect to specific URL',
    'Schedule Setting' => 'Form publication status',
    'description schedule setting' => 'When you change form status to "Published", form appears on page or blog article. Under form status "Published", you can set publication pereiod (start date/time, end date/time) and maximum acceptable number. When you change form status to "Unpublished", form does not appear (prior to all other settings such as publication pereiod).',
    'Mail Setting' => 'Duplicate Mail Setting',
    'User Mail Subject' => 'Mail Subject to Sender',
    'Admin Mail Subject' => 'Mail Subject to Administrator',
    'Mail Header Description' => 'Recommended: Up to 120 charactors per line',
    'Mail Footer Description' => 'Recommended: Up to 120 charactors per line',
    'Title Setting Description' => "Please enter the name of form. It appears as form's header, not affect on form page's TITLE tag.",
    'Mail Setting Description' => 'Send mail content to specified address.',
    'View Sample' => 'Samle: mail to administrator',
    'Data No. Setting Description' => 'Mail data number is serial number count up when sender\'s submitted the form data. Data number can extract by valuable "__%aform-data-id%__" , and you ou can write the valuable on Mail Subject, Mail Header, Mail Footer. 
eg. Mail Subject: "No. __%aform-data-id%__" Inquiry from Web site
You can set offset value to Data number. For example, after you enter offset number as "20", data number starts from 20+1.
If you clear that value, data number starts from 1 again.',
    'mail to description' => 'You can set multi mail addresses to To, CC, BCC. eg. aaa@example.com, bbb@example.com',
    'alert thanks url' => 'You can not set the URL starting with "#".',
    'Input check Setting Description' => '',

# manage_aform_data
    'Manage AForm Data' => 'Manage Form Contact Data',
    'Backup this AForm Data(CSV Download)' => 'Download Contact Data (CSV)',
    'Clear this AForm Data' => 'Clear Form Contact Data',
    'Manage AForm Description.' => 'You can download or clear the contact data',
    'Clear Data Confirm' => 'You are about to clear the contact data.Are you sure?',
    'Received Data' => 'Contact Data',
    'Received Status' => 'Manage Status',
    'Received Comment' => 'Note',
    'Received Data ID' => 'Data Number',
    'Received Datetime' => 'Date / Time',
    'No A-Form Data could be found.' => 'No contact data yet.',
    'Are you sure you want to Delete the selected A-Form Received data?' => 'You are about to delete the contact data. Are you sure?',

# prefecture list
    'PrefectureList' => "'Hokkaido','Aomori','Iwate','Miyagi','Akita','Yamagata','Fukushima','Ibaraki','Tochigi','Gunma','Saitama','Chiba','Tokyo','Kanagawa','Niigata','Toyama','Ishikawa','Fukui','Yamanashi','Nagano','Gifu','Shizuoka','Aichi','Mie','Shiga','Kyoto','Osaka','Hyogo','Nara','Wakayama','Tottori','Shimane','Okayama','Hiroshima','Yamaguchi','Tokushima','Kagawa','Ehime','Kochi','Fukuoka','Saga','Nagasaki','Kumamoto','Oita','Miyazaki','Kagoshima','Okinawa'",

# list input error
    'aform_input_errors' => 'Input Error Report',
    'email_format_error' => 'Mail Address Format Error',
    'zipcode_format_error' => 'Zip code Format Error',
    'tel_format_error' => 'Telephone Number Format Error',
    'url_format_error' => 'URL Format Error',
    'max_length_error' => 'Maximum Length Error',
    'not_selected' => 'Not Selected',
    'empty' => 'Empty',
    'privacy_error' => 'Agree to Privacy Policy Error',
    'Access Info Summary' => 'Form Operation Report',
    'Access Info Summary Description' => 'You can check the form page view and conversion rate.',
    'Input Error Log Description' => "By checking form input error, you can guess visitor's adondon cause and get hints to think improvement plan.",
    'PV' => 'Page View',
    'Conversion Rate Help' => '
If visitor views the page 10 times within 30 minutes, page views are counted as 10, Session number is 1.<br />
Conversion is counted when visitor reach form\'s thank you page.<br />
Conversion rate = Conversion (From send complition) / Page View<br />
',

    'Are you sure you want to Copy the selected A-Form?' => 'Are you sure you want to copy the selected form?',

#engine
    'Acceptance end' => 'Form Publicatin Period End',
    'Double submit warning. Please try again for a while.' => 'Repeated submit prohibited. Please try again after a while.',

#validation
    '[_1]([_2]) format is invalid. ex) foo@example.com (ascii character only)' => '[_1]([_2]) format is invalid. eg. foo@example.com (ascii character only)',
    '[_1]([_2]) format is invalid. ex) 03-1234-5678 (numbers and "-" only)' => '[_1]([_2]) format is invalid. eg. 03-1234-5678 (numbers and "-" only)',
    '[_1]([_2]) format is invalid. ex) http://www.example.com/ (ascii character only)' => '[_1]([_2]) format is invalid. eg. http://www.example.com/ (ascii character only)',
    '[_1]([_2]) format is invalid. ex) 123-4567 (numbers and "-" only)' => '[_1]([_2]) format is invalid. eg. 123-4567 (numbers and "-" only)',
    'Please enter [_1] of [_2] characters.' => 'Please enter [_1] of [_2] characters or less.',

#warning
    '[Important] A-Form The save was failed.' => '[Important] Saving process failed.',

#reserve
    'Manage A-Form Reserve' => 'Manage Reservation',
    'AForm Field Extra Type Reserve' => 'Reservation Calender',
    'tip_reserve' => 'Description for Reservation',
    'reserve parts already exists' => 'Reservation part already exists. You can set only one.',

#payment
    'AForm Field Extra Type Payment' => 'Payment part',
    'tip_payment' => 'Description for Payment',
    'payment parts already exists' => 'Payment part is already exists. You can set only one.',
    'payment parts description' => 'To set the payment method, go Manage A-Form Payment tab.',

#calendar
    'AForm Field Extra Type Calendar' => 'Calendar part',
    'tip_calendar' => 'Description for Calendar',

    'ex) 03-1234-5678' => 'eg. 03-1234-5678',
    'ex) 123-4567' => 'eg. 123-4567',
    'ex) http://www.example.com/' => 'eg. http://www.example.com/',
    'ex) foo@example.com' => 'eg. foo@example.com',

#preload
    'Preload Setting Description' => "If visitor who logged in to the web site as a member (using A-Member function) access the form, the visitor's personal information fill in to fields automatically via A-Member's preload function. To do so, it is necessary that member registration form's specific field ID and the form's field ID are same.",
    'Preload Setting Comment' => "Preload URL's domain and form page's domain must be the same.",

    'AForm Field Type Password' => 'Password Field',

    'Are you sure you want to Copy the A-Form?' => 'Are you sure you want to copy the fomr?',
    'Are you sure you want to Delete the A-Form?' => 'Are you sure you want to delete the form?',

    'Data Status Options Comment' => '
You can set the status by inputting comma-delimited text. First text is treated as default value.
eg. Unanswered,Responding,Resolved',
    'You have successfully changed the AForm data.' => 'You have successfully changed the form data.',
    'Save AForm Data Status and Comment' => 'Save form data status and comment',
    'data_status_options_default' => 'Unanswered,Responding,Resolved',

    "This form is <a href='http://www.ark-web.jp/movabletype/' target='_blank'>A-Form for Movabletype Trial version</a>" => "This form is <a href='http://www.ark-web.jp/movabletype/' target='_blank'>A-Form  for Movable Type Trial version</a>",
    "Please return your browser's back button." => "Please use your browser's Back button to return",
    'Please review contents and then, push the "Send this contents" button.' => 'Please review contents, and push submit button.',
    "To fix contents, please return to your browser's back button." => "To fix contents, please return by using browser's back button.",
    'Send this contents' => 'Submit',
    'AFormData' => 'Contact data',
    'AFormDatas' => 'Contact data',

    'Warning: Create a new form in the System.' => 'You are about to create the form under system menu, that can be be used in multi web sites or blogs. If you want to create the form only for specific blog. please go to that blog, then create the form.',
    'Warning: Create a new form in the [_1].' => '
You are about to create the form under <strong>[_1]</strong> blog, that can be used only in this blog. If you want to use it in multi web site or blogs, please go to system menu, then create the form.',
    'Warning: Copy a new form in the System.' => 'You are about to copy the form under system menu, that can be be used in multi web sites or blogs. If you want to coyp the form only for specific blog. please go to that blog, then create the form.',
    'Warning: Copy a new form in the [_1].' => 'You are about to cpyu the form under <strong>[_1]</strong> blog, that can be used only in this blog. If you want to use it in multi web site or blogs, please go to system menu, then create the form.',

    'Customers Mail Setting' => 'Mail to Customers Setting',
    'Mail From description' => 'You can set only one address',
    'Customers Mail To description' => "Sender's mail address",
    'Admin Mail Setting' => 'Mail to Administrator Setting',
    'Mail To description' => 'You can set multi addresses separated by comma. Max lenngth is about 100 characters.',
    'Customers/Admin Mail Setting description' => '
The text you set here will be inserted to header and footer of mail body.
To insert data number, write variable "__%aform-data-id%__".
To insert the data than sender filled in, write variable "__%PARTS_ID%__" (please replace "PARTS_ID" as actual parts ID).
eg. If you set some parts ID as "name", write "__%name%__".',
    'Members only form Setting Description' => '
To make the form that only logged in mamber can submit, you should call &lt;mt:AMemberCheck&gt; on the page that embedded the form.
And If you want the form that member can submit one time only, set the URL below.',

    'AForm Field Extra Type Name' => 'Name',
    'AForm Field Extra Type Kana' => 'Name Kana',
    'tip_kana' => 'Field parts for Katakana',

    'icon_new_windows' => '', #（mt-static/plugins/AForm/images/icons/icon_new_windows.gif）

    'View AForm' => 'View From',
    'Create and Edit AForm' => 'Create and Edit Form',
    'View and Export AForm data' => 'View and Export Contact Data',
    'Update AForm data' => 'Update Contact Data Status',
    'Delete AForm data' => 'Clear Contact Data',
    'All range' => 'All Period',
    'Specify range' => 'Narrow down Period',
    'View AForm data' => 'View Contact Data',
    'mail_save_data_failed header' => 'Data that may have failed to save',
    'mail_save_data_failed footer' => 'Plese check the form operation status',
    'mail_unpublished_form_access header' => 'Data that have sent to unpublished form',
    'mail_unpublished_form_access footer' => 'Plese check the form operation status',
    'Test A-Form' => 'Normal Form Test',

    'Place AForm' => 'Embedded',
    'No Entry found.' => 'No blog article / web page',
    'Place [_1]' => 'Place [_1]',
    'Place Title' => 'Embedded Page',
);

1;
