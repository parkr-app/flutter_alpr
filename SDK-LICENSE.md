# Parkr ALPR SDK License Agreement

Version 1.0, 23 October 2026

This agreement ("Agreement") is between **Bileier AS**, organization number 932 125 056, Blåsenborgvegen 24, 5355 Knarrevik, Norway ("Bileier"), and the company or person that uses the SDK ("you"). By downloading, installing or using the SDK you accept this Agreement. If you use the SDK on behalf of a company, you accept it for that company.

## 1. Definitions

- **SDK**: the AlprKit binary frameworks for iOS and Android (the "Core"), including the bundled models, resources and documentation, and every update Bileier makes available. The framework wrappers published under the MIT license (such as `react-native-alpr`) are not part of the SDK; they are covered by their own MIT license.
- **Application**: one mobile application identified by one iOS bundle identifier and/or one Android application ID.
- **Basic Features**: live camera scanning with the default overlay, per-frame plate results, camera permission helpers and the developer tools (`showFps`, `mockImage`).
- **Pro Features**: every other feature of the SDK, including recognizing plates in image files, zoom, torch, overlay styling, GPU and Neural Engine acceleration, scan regions, custom thresholds, plate consensus (`onPlate`), country filters and format filters.
- **Development Build**: a debug build, a simulator or emulator build, a TestFlight build, an ad-hoc build, or another build that is not distributed through a public app store or enterprise distribution.
- **License Key**: a key issued by Bileier for one or more Applications.
- **Updates Period**: the period stated in your License Key (`updatesUntil`), normally one year from purchase.

## 2. Free license

Bileier grants you a free, non-exclusive, worldwide, non-transferable license to:

1. use the Basic Features in any Application, including in production; and
2. use the Pro Features in Development Builds, to develop and evaluate your Application.

## 3. Paid and trial licenses

1. **Paid license.** If you buy a License Key, Bileier grants you a perpetual, non-exclusive, worldwide, non-transferable license to use the Pro Features in the Applications listed in the License Key, in production, with every SDK version released during the Updates Period. You may keep using those versions after the Updates Period ends. Versions released after the Updates Period require a renewal.
2. **Trial license.** Bileier may issue a trial License Key that lets you use the Pro Features in production builds of one Application for a limited time. After it expires the Pro Features stop working in production builds; the Basic Features keep working.
3. **Development and staging identifiers.** Bileier adds identifiers with the same base and a suffix such as `.dev`, `.staging` or `.debug` to your License Key at no extra cost.
4. **Business customers only.** Paid licenses are sold to businesses for use in their trade. They are not sold to consumers.

## 4. Distribution

You may distribute the SDK only in compiled form and only as part of your Applications, to end users through app stores, enterprise distribution or direct installation. You may let your employees and contractors use the SDK on your behalf.

## 5. Restrictions

You may not:

1. remove, disable, bypass or work around the license check, or distribute a modified SDK that does so;
2. reverse engineer, decompile or disassemble the SDK, except where the law allows it despite this restriction;
3. distribute the SDK on its own, or as part of a library, SDK, plugin or development tool;
4. use Pro Features in production in Applications that your License Key does not cover;
5. sell, sublicense, rent or share your License Key; or
6. remove copyright notices or third-party notices from the SDK.

## 6. Fees, taxes and refunds

Prices are shown on https://alpr.parkr.app and are paid in advance. Norwegian VAT is added for Norwegian customers. Customers outside Norway account for VAT in their own country (reverse charge). **Fees are non-refundable once a License Key has been issued**, except where mandatory law requires a refund or as stated in section 9. Development Builds, where every Pro Feature works without a License Key, are the evaluation period.

## 7. Telemetry

1. **Build time.** The framework wrappers send a small report when your Application is built. It contains the application identifier, platform, build type, SDK and framework versions, whether the build runs on CI and the license state. It contains no data about end users. Set the environment variable `DO_NOT_TRACK=1` or `ALPR_TELEMETRY=0` to turn it off.
2. **Runtime.** The SDK sends at most one report per day per device. It contains the application identifier and version, platform, OS version, SDK and framework versions, build type, license state and the names of Pro Features that were disabled or used without a license. It never contains device identifiers, user identifiers, images or plate data. Runtime telemetry is on by default for Applications without a license and off by default for licensed Applications. You can change it with `setTelemetryEnabled`, the `AlprTelemetryEnabled` Info.plist key or the `app.parkr.alpr.TELEMETRY_ENABLED` Android manifest entry.
3. Bileier uses telemetry to understand how the SDK is used, to improve it and to contact companies about licensing. Bileier does not store IP addresses with telemetry and does not sell telemetry.

## 8. Data protection

The SDK processes camera frames and images on the end user's device. It does not send images, plate numbers or other personal data to Bileier. You are the controller of any personal data your Application processes, including license plate numbers, and you are responsible for complying with data protection law, such as the GDPR.

## 9. Warranty

Bileier warrants that it has the right to grant the licenses in this Agreement for the parts of the SDK it owns. If this warranty is breached, Bileier will, at its option, fix the problem or end the paid license and refund the fees paid for it. This is your only remedy for a breach of this warranty.

Apart from that, and as far as the law allows, **the SDK is provided "as is"**, without any other warranty or condition, including fitness for a particular purpose, accuracy of recognition results or uninterrupted operation. Plate recognition can be wrong. Do not use the SDK as the only basis for decisions with legal or safety consequences, such as fines, access control or law enforcement, without human review.

## 10. Third-party components

The SDK includes machine-learning models and other components licensed by third parties under their own terms, listed in `THIRD_PARTY_NOTICES.md`. The licensing status of the bundled license plate detection model is not settled, as explained in that file. Bileier gives no warranty and no indemnity for third-party components, and you are responsible for checking that their terms allow your use.

## 11. Limitation of liability

As far as the law allows, Bileier is not liable for indirect, incidental or consequential damages, or for lost profits, revenue, data or goodwill. Bileier's total liability under this Agreement is limited to the fees you paid in the 12 months before the claim, or NOK 1,000 if you use only the free license. These limits do not apply to liability that cannot be limited by law.

## 12. Termination

This Agreement ends automatically if you breach section 5 and do not fix the breach within 30 days of written notice. When it ends, you must stop distributing new builds of your Applications that include the SDK. Sections 5, 7, 8, 9, 10, 11 and 13 survive termination.

## 13. General

1. **Governing law and venue.** This Agreement is governed by Norwegian law. Disputes go to Hordaland tingrett as the agreed venue.
2. **Assignment.** You may assign this Agreement only with Bileier's written consent, except to a successor of your whole business. Bileier may assign it to a successor of its business.
3. **Changes.** Bileier may publish new versions of this Agreement. A new version applies to SDK versions released after it is published. It does not change the terms of SDK versions you already use.
4. **Entire agreement.** This Agreement, together with your order and License Key, is the whole agreement about the SDK. Your purchase-order terms do not apply.
5. **Contact.** post@parkr.app
