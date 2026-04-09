class PolicySection {
  final String heading;
  final String body;
  const PolicySection({required this.heading, required this.body});
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVACY POLICY CONTENT
// ─────────────────────────────────────────────────────────────────────────────

const privacyPolicySections = [
  PolicySection(
    heading: '1. Information We Collect',
    body:
        'We collect information you provide directly to us, such as when you create or modify your account, request on-demand services, contact customer support, or otherwise communicate with us.',
  ),
  PolicySection(
    heading: '2. Use of Information',
    body:
        'We may use the information we collect about you to provide, maintain, and improve our services, including to facilitate payments, send receipts, provide products and services you request (and send related information), develop new features, provide customer support to Users and Drivers, develop safety features, authenticate users, and send product updates and administrative messages.',
  ),
  PolicySection(
    heading: '3. Sharing of Information',
    body:
        'We may share the information we collect about you as described in this Statement or as described at the time of collection or sharing, including as follows: With third parties to provide you a service you requested through a partnership or promotional offering made by a third party or us.',
  ),
  PolicySection(
    heading: '4. Data Security',
    body:
        'We take reasonable measures to help protect information about you from loss, theft, misuse and unauthorized access, disclosure, alteration and destruction.',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// TERMS OF USE CONTENT
// ─────────────────────────────────────────────────────────────────────────────

const termsOfUseSections = [
  PolicySection(
    heading: '1. Acceptance of Terms',
    body:
        'By accessing and using Unflappable, you accept and agree to be bound by the terms and provision of this agreement.',
  ),
  PolicySection(
    heading: '2. User License',
    body:
        "Permission is granted to temporarily download one copy of the materials (information or software) on Unflappable's app for personal, non-commercial transitory viewing only.",
  ),
  PolicySection(
    heading: '3. Disclaimer',
    body:
        "The materials on Unflappable's app are provided on an 'as is' basis. Unflappable makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.",
  ),
  PolicySection(
    heading: '4. Limitations',
    body:
        "In no event shall Unflappable or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on Unflappable's app.",
  ),
];
