// Draft wording: review against actual store practices before publication.
// Each record contains an English heading/body and a Tamil heading/body.
const privacySections = <(String, String, String, String)>[
  (
    'About this policy',
    'Aroun Stores respects your privacy. This policy explains how we handle information when you use our app.',
    'இந்தக் கொள்கை பற்றி',
    'அருண் ஸ்டோர்ஸ் உங்கள் தனியுரிமையை மதிக்கிறது. எங்கள் செயலியைப் பயன்படுத்தும்போது உங்கள் தகவல்களை எவ்வாறு கையாளுகிறோம் என்பதை இந்தக் கொள்கை விளக்குகிறது.',
  ),
  (
    'Information we collect',
    'We collect information you provide, including your name, phone number, delivery address, account details, and order information.',
    'நாங்கள் சேகரிக்கும் தகவல்கள்',
    'உங்கள் பெயர், தொலைபேசி எண், விநியோக முகவரி, கணக்கு விவரங்கள் மற்றும் ஆர்டர் தகவல்கள் உள்ளிட்ட நீங்கள் வழங்கும் தகவல்களைச் சேகரிக்கிறோம்.',
  ),
  (
    'How we use information',
    'We use this information to manage your account, process orders, arrange deliveries, verify payments, and respond to customer enquiries.',
    'தகவல்களைப் பயன்படுத்தும் விதம்',
    'உங்கள் கணக்கை நிர்வகிக்கவும், ஆர்டர்களைச் செயல்படுத்தவும், விநியோகத்தை ஏற்பாடு செய்யவும், பணம் செலுத்தியதைச் சரிபார்க்கவும், வாடிக்கையாளர் கேள்விகளுக்குப் பதிலளிக்கவும் இந்தத் தகவல்களைப் பயன்படுத்துகிறோம்.',
  ),
  (
    'Payments and sharing',
    'Online payments are processed through Razorpay under its privacy policy (https://razorpay.com/privacy-policy/). Relevant information may be shared with payment, delivery, and service providers as needed to fulfil your orders.',
    'பணம் செலுத்துதல் மற்றும் தகவல் பகிர்வு',
    'இணையவழிப் பணப்பரிவர்த்தனைகள் Razorpay மூலம் அதன் தனியுரிமைக் கொள்கையின்படி செயல்படுத்தப்படுகின்றன (https://razorpay.com/privacy-policy/). உங்கள் ஆர்டர்களை நிறைவேற்றத் தேவையான தகவல்கள் பணப்பரிவர்த்தனை, விநியோகம் மற்றும் சேவை வழங்குநர்களுடன் பகிரப்படலாம்.',
  ),
  (
    'Storage and security',
    'Information is retained as needed for service delivery, resolving issues, and applicable record-keeping requirements. No online service can guarantee complete security. Please keep your account credentials private.',
    'தகவல் சேமிப்பு மற்றும் பாதுகாப்பு',
    'சேவை வழங்குதல், சிக்கல்களைத் தீர்த்தல் மற்றும் பொருந்தக்கூடிய பதிவுப் பராமரிப்புத் தேவைகளுக்காகத் தகவல்கள் தேவையான காலம் வரை வைத்திருக்கப்படும். எந்த இணையச் சேவையும் முழுமையான பாதுகாப்பிற்கு உத்தரவாதம் அளிக்க முடியாது. உங்கள் உள்நுழைவு விவரங்களை ரகசியமாக வைத்திருங்கள்.',
  ),
  (
    'Your choices',
    'You may contact Aroun Stores to request access, correction, or deletion of your personal information. Some records may need to be retained for legal requirements or unresolved transactions.',
    'உங்கள் விருப்பங்கள்',
    'உங்கள் தனிப்பட்ட தகவல்களைப் பார்வையிட, திருத்த அல்லது நீக்கக் கோரி அருண் ஸ்டோர்ஸைத் தொடர்புகொள்ளலாம். சட்டத் தேவைகள் அல்லது முடிவடையாத பரிவர்த்தனைகளுக்காகச் சில பதிவுகளை வைத்திருக்க வேண்டியிருக்கலாம்.',
  ),
  (
    'Updates and contact',
    'We may update this policy as our services change. For privacy questions, contact the store through its published contact details.',
    'மாற்றங்கள் மற்றும் தொடர்பு',
    'எங்கள் சேவைகள் மாறும்போது இந்தக் கொள்கையைப் புதுப்பிக்கலாம். தனியுரிமை தொடர்பான கேள்விகளுக்கு, கடை வெளியிட்டுள்ள தொடர்பு விவரங்கள் மூலம் எங்களை அணுகவும்.',
  ),
];

const termsSections = <(String, String, String, String)>[
  (
    'Using our service',
    'Please provide accurate account and delivery information and use the Aroun Stores app lawfully. Keep your login details confidential.',
    'எங்கள் சேவையைப் பயன்படுத்துதல்',
    'சரியான கணக்கு மற்றும் விநியோகத் தகவல்களை வழங்கி, அருண் ஸ்டோர்ஸ் செயலியைச் சட்டப்படி பயன்படுத்தவும். உங்கள் உள்நுழைவு விவரங்களை ரகசியமாக வைத்திருக்கவும்.',
  ),
  (
    'Products and availability',
    'Products are subject to availability. Images are illustrative; actual packaging and fresh produce may vary. Check product descriptions and labels for ingredients and allergy information.',
    'பொருட்கள் மற்றும் இருப்பு',
    'பொருட்கள் இருப்புக்கு உட்பட்டவை. படங்கள் விளக்கத்திற்காக மட்டுமே; உண்மையான பேக்கிங் மற்றும் புதிய விளைபொருட்களின் தோற்றம் மாறுபடலாம். மூலப்பொருட்கள் மற்றும் ஒவ்வாமைத் தகவல்களுக்கு பொருள் விவரங்களையும் லேபிள்களையும் சரிபார்க்கவும்.',
  ),
  (
    'Prices and payments',
    'Review prices, quantities, delivery charges, and the total before placing an order. Prices and offers may change for future purchases. Use only payment methods you are authorised to use.',
    'விலைகள் மற்றும் பணம் செலுத்துதல்',
    'ஆர்டர் செய்வதற்கு முன் விலைகள், அளவுகள், விநியோகக் கட்டணம் மற்றும் மொத்தத் தொகையைச் சரிபார்க்கவும். எதிர்காலக் கொள்முதல்களுக்கு விலைகளும் சலுகைகளும் மாறலாம். நீங்கள் பயன்படுத்த அனுமதிக்கப்பட்ட பணம் செலுத்தும் முறைகளை மட்டுமே பயன்படுத்தவும்.',
  ),
  (
    'Orders and delivery',
    'Orders are subject to availability and payment verification. Provide a complete address and reachable phone number. Delivery estimates may be affected by stock, traffic, weather, or operational delays.',
    'ஆர்டர்கள் மற்றும் விநியோகம்',
    'ஆர்டர்கள் பொருள் இருப்பு மற்றும் பணப்பரிவர்த்தனைச் சரிபார்ப்புக்கு உட்பட்டவை. முழுமையான முகவரியையும் தொடர்புகொள்ளக்கூடிய தொலைபேசி எண்ணையும் வழங்கவும். இருப்பு, போக்குவரத்து, வானிலை அல்லது செயல்பாட்டுத் தாமதங்களால் விநியோக நேரம் மாறலாம்.',
  ),
  (
    'Cancellations, returns, and refunds',
    'Contact the store promptly for cancellation requests or missing, damaged, or incorrect items. Available remedies depend on the product, order status, policies disclosed before purchase, and applicable consumer rights. Refund processing times depend on the payment provider and bank.',
    'ரத்து செய்தல், திருப்பி அளித்தல் மற்றும் பணத்தைத் திரும்பப் பெறுதல்',
    'ஆர்டரை ரத்து செய்ய அல்லது பொருட்கள் விடுபட்டிருந்தால், சேதமடைந்திருந்தால் அல்லது தவறாக வந்திருந்தால் கடையை உடனடியாகத் தொடர்புகொள்ளவும். தீர்வுகள் பொருள், ஆர்டர் நிலை, வாங்குவதற்கு முன் தெரிவிக்கப்பட்ட கொள்கைகள் மற்றும் பொருந்தக்கூடிய நுகர்வோர் உரிமைகளைப் பொறுத்தவை. பணத்தைத் திருப்பிச் செலுத்தும் காலம் பணப்பரிவர்த்தனை வழங்குநரையும் வங்கியையும் பொறுத்தது.',
  ),
  (
    'Support and changes',
    'Contact the store with your order reference for assistance. These terms may be updated, without removing rights relating to purchases already made.',
    'உதவி மற்றும் மாற்றங்கள்',
    'உதவி பெற உங்கள் ஆர்டர் எண்ணுடன் கடையைத் தொடர்புகொள்ளவும். ஏற்கனவே செய்த கொள்முதல்கள் தொடர்பான உரிமைகளை நீக்காமல் இந்த விதிமுறைகள் புதுப்பிக்கப்படலாம்.',
  ),
];
