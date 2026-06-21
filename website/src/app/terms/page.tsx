"use client";

import React from "react";
import { ArrowLeft, BookOpen } from "lucide-react";

export default function TermsOfService() {
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
              <BookOpen size={24} className="stroke-[3]" />
            </div>
            <h1 className="font-display text-2xl sm:text-4xl font-black uppercase">
              TERMS OF SERVICE
            </h1>
          </div>

          <div className="space-y-6 text-sm font-bold leading-relaxed text-gray-800 uppercase">
            <p className="text-xs text-gray-600 font-black">LAST UPDATED: JUNE 19, 2026</p>

            <section className="space-y-2">
              <h2 className="text-base font-black text-black border-b-2 border-black pb-1">1. AGREEMENT TO TERMS</h2>
              <p>
                BY ACCESSING OR USING HUNARLOOP, YOU AGREE TO BE BOUND BY THESE TERMS OF SERVICE. IF YOU DO NOT AGREE TO ALL OF THESE TERMS, YOU ARE EXPRESSLY PROHIBITED FROM USING OUR SERVICES.
              </p>
            </section>

            <section className="space-y-2">
              <h2 className="text-base font-black text-black border-b-2 border-black pb-1">2. MARKETPLACE SERVICES</h2>
              <p>
                HUNARLOOP OPERATES AN HYPERLOCAL SKILL MARKETPLACE THAT FACILITATES THE BOOKING OF SKILLED GIG WORKERS. HUNARLOOP IS AN INTERMEDIARY AND IS NOT AN EMPLOYER. WE PROCESS ESCROW PAYMENTS AND COMPUTE VERIFIED TRUST SCORES BUT DO NOT DIRECTLY EMPLOY WORKER PARTNERS.
              </p>
            </section>

            <section className="space-y-2">
              <h2 className="text-base font-black text-black border-b-2 border-black pb-1">3. USER ACCOUNTS</h2>
              <p>
                TO ACCESS MARKETPLACE BOOKINGS, USERS MUST CREATE AN ACCOUNT SECURED BY EMAIL/PASSWORD OR GOOGLE SIGN-IN. YOU AGREE TO:
              </p>
              <ul className="list-disc list-inside pl-4 space-y-1">
                <li>PROVIDE ACCURATE, CURRENT, AND COMPLETE INFORMATION.</li>
                <li>MAINTAIN THE SECURITY OF YOUR LOGINS AND CREDENTIALS.</li>
                <li>PROMPTLY NOTIFY US OF ANY BREACH OF ACCOUNT SECURITY.</li>
              </ul>
            </section>

            <section className="space-y-2">
              <h2 className="text-base font-black text-black border-b-2 border-black pb-1">4. ESCROW PAYMENT TERMS</h2>
              <p>
                ALL GIG BOOKINGS MUST BE PRE-FUNDED BY CUSTOMERS UPFRONT. FUNDS ARE SECURELY DEPOSITED INTO A RAZORPAY-POWERED ESCROW ROUTE HOLDING ACCOUNT.
              </p>
              <p>
                ESCROW FUNDS ARE RELEASED TO THE WORKER'S LINKED UPI OR BANK ACCOUNT EITHER:
              </p>
              <ul className="list-disc list-inside pl-4 space-y-1">
                <li>IMMEDIATELY UPON CUSTOMER APPROVAL IN THE SYSTEM.</li>
                <li>AUTOMATICALLY AFTER 24 HOURS OF JOB COMPLETION TIMER LAPSE, UNLESS A FORMAL DISPUTE IS FILED.</li>
              </ul>
            </section>

            <section className="space-y-2">
              <h2 className="text-base font-black text-black border-b-2 border-black pb-1">5. USER CONDUCT & VERIFICATION</h2>
              <p>
                WORKER PARTNERS MUST SUBMIT TRUTHFUL CREDENTIALS, KYC DETAILS, AND WORK DEMO VIDEOS FOR GOOGLE GEMINI AI ASSESSMENT. CUSTOMERS AND WORKERS SHALL ENGAGE IN A RESPECTFUL MANNER.
              </p>
            </section>

            <section className="space-y-2">
              <h2 className="text-base font-black text-black border-b-2 border-black pb-1">6. LIMITATION OF LIABILITY</h2>
              <p>
                HUNARLOOP IS NOT LIABLE FOR THE QUALITY, SAFETY, OR LEGALITY OF GIG SERVICES PERFORMED. DISPUTES REGARDING WORK PERFORMANCE SHALL BE RESOLVED ACCORDING TO OUR ESCROW DISPUTE SETTLEMENT GUIDELINES.
              </p>
            </section>
          </div>
        </div>
      </main>
    </div>
  );
}
