"use client";

import React from "react";
import { ArrowLeft, Coins } from "lucide-react";

export default function RefundPolicy() {
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
              <Coins size={24} className="stroke-[3]" />
            </div>
            <h1 className="font-display text-2xl sm:text-4xl font-black uppercase">
              REFUND & ESCROW DISPUTE POLICY
            </h1>
          </div>

          <div className="space-y-6 text-sm font-bold leading-relaxed text-gray-800 uppercase">
            <p className="text-xs text-gray-600 font-black">LAST UPDATED: JUNE 19, 2026</p>

            <section className="space-y-2">
              <h2 className="text-base font-black text-black border-b-2 border-black pb-1">1. ESCROW SYSTEM AND DISPUTES</h2>
              <p>
                HUNARLOOP ENFORCES AN ESCROW PROTECTION SYSTEM POWERED BY RAZORPAY. PAYMENT FOR EACH BOOKING IS PRE-AUTHORIZED AND HELD IN OUR TRANSACTION GATEWAY SECURELY. RELEASE OF ESCROW IS TRIGGERED UPON USER APPROVAL OR A 24-HOUR AUTO-TIMEOUT.
              </p>
            </section>

            <section className="space-y-2">
              <h2 className="text-base font-black text-black border-b-2 border-black pb-1">2. BOOKING CANCELLATION BY CUSTOMER</h2>
              <p>
                - CANCELLATION MORE THAN 2 HOURS BEFORE THE SCHEDULED SLOT: 100% REFUND IS CREDITED TO THE ORIGINAL PAYMENT SOURCE.
              </p>
              <p>
                - CANCELLATION WITHIN 2 HOURS OF THE SCHEDULED SLOT: A CANCELLATION CONVENIENCE FEE OF ₹100 IS DEDUCTED TO COMPENSATE THE ASSIGNED WORKER FOR OPPORTUNITY LOSS. THE REMAINING AMOUNT IS REFUNDED.
              </p>
            </section>

            <section className="space-y-2">
              <h2 className="text-base font-black text-black border-b-2 border-black pb-1">3. CANCELLATION OR NO-SHOW BY WORKER</h2>
              <p>
                IF AN ASSIGNED WORKER FAILS TO SHOW UP AT the SCHEDULED TIME OR CANCELS THE GIG, A 100% REFUND (INCLUDING HANDING FEES & GST) IS INSTANTLY TRANSFERRED BACK TO THE CUSTOMER'S ORIGINAL PAYMENT SOURCE. NO FEES ARE DEDUCTED.
              </p>
            </section>

            <section className="space-y-2">
              <h2 className="text-base font-black text-black border-b-2 border-black pb-1">4. WORK QUALITY DISPUTES</h2>
              <p>
                IF YOU ARE UNSATISFIED WITH THE QUALITY OF THE WORK COMPLETED, YOU MUST **NOT** MARK THE JOB AS COMPLETED IN THE APPLICATION. INSTEAD:
              </p>
              <ul className="list-disc list-inside pl-4 space-y-1">
                <li>CLICK "RAISE A DISPUTE" IN THE APP DETAILS SCREEN WITHIN the 24-HOUR OF GIG COMPLETION.</li>
                <li>SUBMIT DESCRIPTION PHOTOS OF the DISPUTED TASK.</li>
                <li>HUNARLOOP'S IN-HOUSE ARBITRATION TEAM WILL AUDIT THE BOOKING DESCRIPTION AND MUTUAL CHATS.</li>
                <li>RESOLUTIONS WILL BE CONCLUDED WITHIN 3 WORKING DAYS. TRANSFERS WILL BE ROUTED ACCORDING TO MUTUAL COMPROMISE OR FACTUAL COMPLETION DATA.</li>
              </ul>
            </section>

            <section className="space-y-2">
              <h2 className="text-base font-black text-black border-b-2 border-black pb-1">5. REFUND TIMELINES</h2>
              <p>
                ONCE A REFUND IS CONCLUDED AND INITIATED, THE TRANSFERS WILL REFLECT IN the CUSTOMER'S BANK ACCOUNT OR UPI SOURCE WITHIN 5 TO 7 WORKING DAYS, SUBJECT TO BANK SETTLEMENT SCHEDULES.
              </p>
            </section>
          </div>
        </div>
      </main>
    </div>
  );
}
