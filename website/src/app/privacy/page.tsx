"use client";

import React from "react";
import { ArrowLeft, Shield } from "lucide-react";

export default function PrivacyPolicy() {
  return (
    <div className="min-h-screen bg-[#FFE600] text-black selection:bg-black selection:text-[#FFE600] font-sans pb-16">
      {/* PERSISTENT HEADER */}
      <header className="sticky top-0 z-50 w-full bg-white border-b-4 border-black px-6 py-4">
        <div className="max-w-7xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-3">
            <a href="/" className="w-10 h-10 brutalist-border bg-[#FFE600] flex items-center justify-center font-black text-xl brutalist-shadow-sm">
              HL
            </a>
            <div>
              <span className="font-display text-lg font-black tracking-tight text-black uppercase">
                HunarLoop
              </span>
            </div>
          </div>
          <a
            href="/"
            className="brutalist-button text-xs uppercase px-4 py-2 flex items-center gap-1.5"
          >
            <ArrowLeft size={14} className="stroke-[3]" /> Back to Home
          </a>
        </div>
      </header>

      {/* CONTENT AREA */}
      <main className="max-w-4xl mx-auto px-6 pt-12">
        <div className="bg-white brutalist-border p-8 brutalist-shadow-lg rounded-none">
          <div className="flex items-center gap-3 border-b-3 border-black pb-4 mb-6">
            <div className="p-2 bg-[#FFE600] brutalist-border">
              <Shield size={24} className="stroke-[3]" />
            </div>
            <h1 className="font-display text-2xl sm:text-4xl font-black uppercase">
              PRIVACY POLICY
            </h1>
          </div>

          <div className="space-y-6 text-sm font-bold leading-relaxed text-gray-800 uppercase">
            <p className="text-xs text-gray-600 font-black">LAST UPDATED: JUNE 19, 2026</p>

            <section className="space-y-2">
              <h2 className="text-base font-black text-black border-b-2 border-black pb-1">1. INTRODUCTION</h2>
              <p>
                WELCOM TO HUNARLOOP. WE VALUE YOUR PRIVACY AND ARE COMMITTED TO PROTECTING YOUR PERSONAL DATA. THIS PRIVACY POLICY EXPLAINS HOW WE COLLECT, USE, DISCLOSE, AND SAFEGUARD YOUR INFORMATION WHEN YOU VISIT OUR MARKETING WEBSITE OR USE OUR HYPERLOCAL MOBILE APPLICATION.
              </p>
            </section>

            <section className="space-y-2">
              <h2 className="text-base font-black text-black border-b-2 border-black pb-1">2. INFORMATION WE COLLECT</h2>
              <p>
                WE COLLECT DATA TO PROVIDE BETTER SERVICES TO ALL OUR USERS. THIS INCLUDES:
              </p>
              <ul className="list-disc list-inside pl-4 space-y-1">
                <li>IDENTITY DATA: NAME, PHONE NUMBER, EMAIL ADDRESS, AND ROLE (CUSTOMER OR WORKER).</li>
                <li>LOCATION DATA: GEOLOCATION DATA FROM MOBILE DEVICES TO ENABLE HYPERLOCAL MATCHING.</li>
                <li>TRANSACTION DATA: RECORD OF BOOKINGS, ESCROW PAYMENTS, AND TRANSFERS PROCESSED BY RAZORPAY.</li>
                <li>MEDIA DATA: SKILL VIDEO DEMOS CAPTURED AND UPLOADED FOR AI PROFICIENCY TESTING.</li>
              </ul>
            </section>

            <section className="space-y-2">
              <h2 className="text-base font-black text-black border-b-2 border-black pb-1">3. HOW WE USE YOUR INFORMATION</h2>
              <p>
                WE USE THE COLLECTED DATA FOR THE FOLLOWING PURPOSES:
              </p>
              <ul className="list-disc list-inside pl-4 space-y-1">
                <li>TO PERSONALIZE AND ENABLE HYPERLOCAL MATCHES BETWEEN CUSTOMERS AND WORKERS.</li>
                <li>TO EVALUATE SKILL VIDEOS VIA GOOGLE GEMINI AI AND CALCULATE THE HUNAR TRUST SCORE.</li>
                <li>TO HOLD AND ROUTE FUNDS VIA RAZORPAY ESCROW GATEWAYS SAFELY.</li>
                <li>TO IMPROVE SECURITY AND VERIFY IDENTITY VIA AADHAAR KYC INTEGRATIONS.</li>
              </ul>
            </section>

            <section className="space-y-2">
              <h2 className="text-base font-black text-black border-b-2 border-black pb-1">4. DATA SHARING & STORAGE</h2>
              <p>
                WE DO NOT SELL YOUR PERSONAL DATA. YOUR LOCATION AND CONTACT DETAILS ARE ONLY SHARED WITH A MATCHED WORKER OR CUSTOMER ONCE A CONFIRMED BOOKING IS DEPOSITED IN ESCROW.
              </p>
              <p>
                ALL USER PROFILES AND BOOKINGS DATA ARE STORED SECURELY IN THE FIREBASE CLOUD DATABASE AND SECURED BY ROBUST ACCESS RULES.
              </p>
            </section>

            <section className="space-y-2">
              <h2 className="text-base font-black text-black border-b-2 border-black pb-1">5. SECURITY MEASURES</h2>
              <p>
                WE ENFORCE SECURE ACCESS MECHANISMS INCLUDING FIREBASE AUTHENTICATION (EMAIL/PASSWORD, GOOGLE SIGN-IN) AND ENCRYPTED ESCROW GATEWAYS TO ENSURE SYSTEM SAFETY.
              </p>
            </section>

            <section className="space-y-2">
              <h2 className="text-base font-black text-black border-b-2 border-black pb-1">6. CONTACT US</h2>
              <p>
                IF YOU HAVE QUESTIONS OR CONCERNS ABOUT THIS PRIVACY POLICY, PLEASE EMAIL US AT SUPPORT@HUNARLOOP.IN OR VISIT OUR REGISTERED OFFICE IN HAZRATGANJ, LUCKNOW, INDIA.
              </p>
            </section>
          </div>
        </div>
      </main>
    </div>
  );
}
