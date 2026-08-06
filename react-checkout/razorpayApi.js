const DEFAULT_HEADERS = {
  Accept: 'application/json',
  'Content-Type': 'application/json',
};

function buildAuthHeaders(token) {
  if (!token) return {};
  return {
    Authorization: token.startsWith('Bearer ') ? token : `Bearer ${token}`,
  };
}

async function readJson(response) {
  const contentType = response.headers.get('content-type') || '';
  if (!contentType.includes('application/json')) {
    return { raw: await response.text() };
  }

  return response.json();
}

export async function createRazorpayOrder({
  endpoint = '/api/payment/create-order',
  amount,
  currency = 'INR',
  cartItems = [],
  shippingDetails = {},
  authToken,
  credentials = 'include',
  signal,
}) {
  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      ...DEFAULT_HEADERS,
      ...buildAuthHeaders(authToken),
    },
    credentials,
    signal,
    body: JSON.stringify({
      amount,
      currency,
      cartItems,
      shippingDetails,
    }),
  });

  const data = await readJson(response);

  if (!response.ok) {
    const message =
      data?.message ||
      data?.error ||
      data?.raw ||
      `Failed to create order (${response.status})`;
    throw new Error(message);
  }

  return data;
}

export async function verifyRazorpayPayment({
  endpoint = '/api/payment/verify',
  payload,
  authToken,
  credentials = 'include',
  signal,
}) {
  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      ...DEFAULT_HEADERS,
      ...buildAuthHeaders(authToken),
    },
    credentials,
    signal,
    body: JSON.stringify(payload),
  });

  const data = await readJson(response);

  if (!response.ok) {
    const message =
      data?.message ||
      data?.error ||
      data?.raw ||
      `Failed to verify payment (${response.status})`;
    throw new Error(message);
  }

  return data;
}

let razorpayScriptPromise = null;

export function loadRazorpayCheckoutScript() {
  if (typeof window === 'undefined') {
    return Promise.reject(new Error('Razorpay Checkout can only load in the browser.'));
  }

  if (window.Razorpay) {
    return Promise.resolve(true);
  }

  if (razorpayScriptPromise) {
    return razorpayScriptPromise;
  }

  razorpayScriptPromise = new Promise((resolve, reject) => {
    const existingScript = document.querySelector('script[data-razorpay-checkout="true"]');

    if (existingScript) {
      existingScript.addEventListener('load', () => resolve(true), { once: true });
      existingScript.addEventListener(
        'error',
        () => reject(new Error('Failed to load Razorpay Checkout script.')),
        { once: true },
      );
      return;
    }

    const script = document.createElement('script');
    script.src = 'https://checkout.razorpay.com/v1/checkout.js';
    script.async = true;
    script.defer = true;
    script.dataset.razorpayCheckout = 'true';
    script.onload = () => resolve(true);
    script.onerror = () => reject(new Error('Failed to load Razorpay Checkout script.'));

    document.head.appendChild(script);
  });

  return razorpayScriptPromise;
}

export function formatCurrency(amount, currency = 'INR') {
  try {
    return new Intl.NumberFormat('en-IN', {
      style: 'currency',
      currency,
      maximumFractionDigits: 2,
    }).format(amount);
  } catch {
    return `${currency} ${Number(amount || 0).toFixed(2)}`;
  }
}

