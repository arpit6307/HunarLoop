"use client";

import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Sparkles,
  MapPin,
  Calendar,
  Lock,
  Video,
  TrendingUp,
  User,
  Search,
  CheckCircle,
  Clock,
  ArrowRight,
  Shield,
  ShieldCheck,
  Star,
  ChevronRight,
  Tv,
  Coins,
  ChevronDown,
  ChevronUp,
  Smartphone,
  Info,
  Wrench,
  BookOpen,
  Palette,
  Utensils,
  Camera,
  Paintbrush,
  Zap,
  Scissors,
  Heart,
  Activity,
  Wind,
  Menu,
  X
} from "lucide-react";

// Categories data with Lucide Icon components
const CATEGORIES = [
  { name: "Plumber", icon: Wrench, color: "bg-[#AED8F2]" },
  { name: "Home Tutor", icon: BookOpen, color: "bg-[#BFF0D4]" },
  { name: "Mehendi Artist", icon: Palette, color: "bg-[#F7C6D9]" },
  { name: "Cook/Chef", icon: Utensils, color: "bg-[#FEDCA9]" },
  { name: "Photographer", icon: Camera, color: "bg-[#D8C7FF]" },
  { name: "Interior Decorator", icon: Paintbrush, color: "bg-[#C4ECC8]" },
  { name: "Electrician", icon: Zap, color: "bg-[#FFF4A3]" },
  { name: "Darzi / Tailor", icon: Scissors, color: "bg-[#FFC0BD]" },
  { name: "Pet Groomer", icon: Heart, color: "bg-[#B4FAFF]" },
  { name: "Personal Trainer", icon: Activity, color: "bg-[#FFD1B3]" },
  { name: "Beautician", icon: Sparkles, color: "bg-[#E6C6FF]" },
  { name: "AC Technician", icon: Wind, color: "bg-[#C8E1FF]" }
];

const SKILL_PRESETS = [
  { name: "Plumber", rate: 350 },
  { name: "Home Tutor", rate: 450 },
  { name: "Mehendi Artist", rate: 600 },
  { name: "Cook/Chef", rate: 300 },
  { name: "Photographer", rate: 1000 },
  { name: "Beautician", rate: 500 }
];

export default function Home() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  // Calculator States
  const [selectedSkill, setSelectedSkill] = useState("Plumber");
  const [hourlyRate, setHourlyRate] = useState(350);
  const [hoursPerWeek, setHoursPerWeek] = useState(30);

  // FAQ states
  const [openFaq, setOpenFaq] = useState<number | null>(null);

  // Live Matching Simulation States
  const [matchingStep, setMatchingStep] = useState(0);
  const matchingScenarios = [
    { text: "Searching for 'electrician near Hazratganj'...", type: "search" },
    { text: "AI analyzing availability & trust scores...", type: "analysis" },
    { text: "Verifying credentials & live rating metrics...", type: "verify" },
    { text: "Match Found! Sunil Kumar (Hunar Score: 94) is 1.5km away", type: "match" }
  ];

  // Scroll to Top state & listener
  const [showScrollTop, setShowScrollTop] = useState(false);

  // Policy Modal state
  const [activePolicy, setActivePolicy] = useState<"privacy" | "terms" | "refund" | null>(null);

  const policyContent = {
    privacy: {
      title: "Privacy Policy",
      updated: "JUNE 19, 2026",
      sections: [
        {
          title: "1. INTRODUCTION",
          content: "WELCOME TO HUNARLOOP. WE VALUE YOUR PRIVACY AND ARE COMMITTED TO PROTECTING YOUR PERSONAL DATA. THIS PRIVACY POLICY EXPLAINS HOW WE COLLECT, USE, DISCLOSE, AND SAFEGUARD YOUR INFORMATION WHEN YOU VISIT OUR MARKETING WEBSITE OR USE OUR HYPERLOCAL MOBILE APPLICATION."
        },
        {
          title: "2. INFORMATION WE COLLECT",
          content: "WE COLLECT DATA TO PROVIDE BETTER SERVICES TO ALL OUR USERS. THIS INCLUDES: IDENTITY DATA (NAME, PHONE NUMBER, EMAIL ADDRESS, ROLE); LOCATION DATA (GEOLOCATION DATA TO ENABLE HYPERLOCAL MATCHING); TRANSACTION DATA (BOOKINGS AND ESCROW PAYMENTS); MEDIA DATA (SKILL DEMO VIDEOS UPLOADED FOR AI PROFICIENCY TESTING)."
        },
        {
          title: "3. HOW WE USE YOUR INFORMATION",
          content: "WE USE COLLECTED DATA TO PERSONALIZE HYPERLOCAL MATCHES, EVALUATE SKILL VIDEOS VIA GOOGLE GEMINI AI, ROUTE ESCROW FUNDS SECURELY VIA RAZORPAY, AND IMPROVE SYSTEM SAFETY AND SECURITY."
        },
        {
          title: "4. DATA SHARING & STORAGE",
          content: "WE DO NOT SELL YOUR PERSONAL DATA. CONTACT DETAILS ARE ONLY SHARED ONCE A CONFIRMED BOOKING IS DEPOSITED IN ESCROW. ALL USER PROFILES AND BOOKINGS DATA ARE STORED SECURELY IN FIREBASE CLOUD DATABASE."
        },
        {
          title: "5. SECURITY MEASURES",
          content: "WE ENFORCE SECURE ACCESS MECHANISMS INCLUDING FIREBASE AUTHENTICATION (EMAIL/PASSWORD, GOOGLE SIGN-IN) AND ENCRYPTED ESCROW GATEWAYS TO ENSURE SYSTEM SAFETY."
        },
        {
          title: "6. CONTACT US",
          content: "EMAIL US AT SUPPORT@HUNARLOOP.IN OR VISIT OUR REGISTERED OFFICE IN HAZRATGANJ, LUCKNOW, INDIA."
        }
      ]
    },
    terms: {
      title: "Terms of Service",
      updated: "JUNE 19, 2026",
      sections: [
        {
          title: "1. AGREEMENT TO TERMS",
          content: "BY ACCESSING OR USING HUNARLOOP, YOU AGREE TO BE BOUND BY THESE TERMS OF SERVICE. IF YOU DO NOT AGREE TO ALL OF THESE TERMS, YOU ARE EXPRESSLY PROHIBITED FROM USING OUR SERVICES."
        },
        {
          title: "2. MARKETPLACE SERVICES",
          content: "HUNARLOOP OPERATES AN HYPERLOCAL SKILL MARKETPLACE THAT FACILITATES THE BOOKING OF SKILLED GIG WORKERS. HUNARLOOP IS AN INTERMEDIARY AND IS NOT AN EMPLOYER. WE PROCESS ESCROW PAYMENTS AND COMPUTE VERIFIED TRUST SCORES BUT DO NOT DIRECTLY EMPLOY WORKER PARTNERS."
        },
        {
          title: "3. USER ACCOUNTS",
          content: "TO ACCESS MARKETPLACE BOOKINGS, USERS MUST CREATE AN ACCOUNT SECURED BY EMAIL/PASSWORD OR GOOGLE SIGN-IN. YOU AGREE TO PROVIDE ACCURATE, CURRENT, AND COMPLETE INFORMATION."
        },
        {
          title: "4. ESCROW PAYMENT TERMS",
          content: "ALL GIG BOOKINGS MUST BE PRE-FUNDED BY CUSTOMERS UPFRONT. FUNDS ARE SECURELY DEPOSITED INTO A RAZORPAY-POWERED ESCROW HOLDING ACCOUNT. ESCROW FUNDS ARE RELEASED TO THE WORKER IMMEDIATELY UPON CUSTOMER APPROVAL OR AUTOMATICALLY AFTER 24 HOURS OF JOB COMPLETION TIMER LAPSE."
        },
        {
          title: "5. LIMITATION OF LIABILITY",
          content: "HUNARLOOP IS NOT LIABLE FOR THE QUALITY, SAFETY, OR LEGALITY OF GIG SERVICES PERFORMED. DISPUTES REGARDING WORK PERFORMANCE SHALL BE RESOLVED ACCORDING TO OUR ESCROW DISPUTE SETTLEMENT GUIDELINES."
        }
      ]
    },
    refund: {
      title: "Refund & Escrow Dispute Policy",
      updated: "JUNE 19, 2026",
      sections: [
        {
          title: "1. ESCROW SYSTEM AND DISPUTES",
          content: "HUNARLOOP ENFORCES AN ESCROW PROTECTION SYSTEM POWERED BY RAZORPAY. PAYMENT FOR EACH BOOKING IS PRE-AUTHORIZED AND HELD IN OUR TRANSACTION GATEWAY SECURELY. RELEASE OF ESCROW IS TRIGGERED UPON USER APPROVAL OR A 24-HOUR AUTO-TIMEOUT."
        },
        {
          title: "2. BOOKING CANCELLATION BY CUSTOMER",
          content: "CANCELLATION MORE THAN 2 HOURS BEFORE THE SLOT: 100% REFUND IS CREDITED TO ORIGINAL SOURCE. CANCELLATION WITHIN 2 HOURS OF SLOT: A FEE OF ₹100 IS DEDUCTED TO COMPENSATE WORKER, REMAINING IS REFUNDED."
        },
        {
          title: "3. CANCELLATION BY WORKER",
          content: "IF AN ASSIGNED WORKER FAILS TO SHOW UP OR CANCELS, A 100% REFUND (INCLUDING FEES AND GST) IS INSTANTLY TRANSFERRED BACK TO CUSTOMER SOURCE. NO FEES ARE DEDUCTED."
        },
        {
          title: "4. WORK QUALITY DISPUTES",
          content: "IF YOU ARE UNSATISFIED WITH WORK QUALITY, YOU MUST NOT MARK THE JOB COMPLETED. INSTEAD, CLICK 'RAISE A DISPUTE' WITHIN 24 HOURS, SUBMIT PHOTOS, AND OUR ARBITRATION TEAM WILL RESOLVE IT WITHIN 3 WORKING DAYS."
        },
        {
          title: "5. REFUND TIMELINES",
          content: "ONCE A REFUND IS CONCLUDED, TRANSFERS WILL REFLECT IN THE CUSTOMER SOURCE WITHIN 5 TO 7 WORKING DAYS."
        }
      ]
    }
  };

  useEffect(() => {
    const handleScroll = () => {
      if (window.scrollY > 300) {
        setShowScrollTop(true);
      } else {
        setShowScrollTop(false);
      }
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  useEffect(() => {
    const interval = setInterval(() => {
      setMatchingStep((prev) => (prev + 1) % matchingScenarios.length);
    }, 3000);
    return () => clearInterval(interval);
  }, []);

  const handleSkillPresetChange = (name: string, rate: number) => {
    setSelectedSkill(name);
    setHourlyRate(rate);
  };

  const calculatedWeekly = hourlyRate * hoursPerWeek;
  const calculatedMonthly = Math.round(calculatedWeekly * 4.33);
  const platformFee = Math.round(calculatedMonthly * 0.1);
  const netEarnings = calculatedMonthly - platformFee;

  return (
    <div className="min-h-screen bg-[#FFE600] text-black selection:bg-black selection:text-[#FFE600] overflow-x-hidden font-sans pb-12">
      
      {/* NAVBAR */}
      <header className="fixed top-0 left-0 right-0 z-50 w-full bg-white border-b-4 border-black px-4 py-3 md:px-6 md:py-4">
        <div className="max-w-7xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-3">
            <img 
              src="/logo.svg" 
              alt="HunarLoop Logo" 
              className="w-10 h-10 md:w-12 md:h-12 brutalist-border bg-transparent"
            />
            <div>
              <span className="font-display text-xl md:text-2xl font-black tracking-tight text-black uppercase">
                Hunar<span className="bg-black text-[#FFE600] px-1 ml-0.5">Loop</span>
              </span>
              <span className="block text-[7px] md:text-[8px] font-black tracking-widest uppercase text-black">
                Jahan Har Hunar Ki Value Hai
              </span>
            </div>
          </div>

          <nav className="hidden md:flex items-center gap-6 text-xs font-black uppercase text-black">
            <a href="#features" className="hover:underline underline-offset-4 decoration-4">How It Works</a>
            <a href="#bento" className="hover:underline underline-offset-4 decoration-4">Features</a>
            <a href="#workers" className="hover:underline underline-offset-4 decoration-4">For Workers</a>
            <a href="#calculator" className="hover:underline underline-offset-4 decoration-4">Calculator</a>
            <a href="/admin" className="hover:underline underline-offset-4 decoration-4 text-red-600 font-extrabold">Admin Panel</a>
          </nav>

          <div className="hidden md:flex items-center gap-4">
            <a
              href="/admin"
              className="brutalist-button text-xs uppercase px-4 py-2.5 rounded-none flex items-center gap-1.5"
            >
              Admin Panel <ShieldCheck size={14} className="stroke-[3]" />
            </a>
            <a
              href="#download"
              className="brutalist-button text-xs uppercase px-4 py-2.5 rounded-none flex items-center gap-1.5"
            >
              Get App <ArrowRight size={14} className="stroke-[3]" />
            </a>
          </div>

          {/* Hamburger Menu Toggle */}
          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="md:hidden p-2 brutalist-border bg-[#FFE600] text-black brutalist-shadow-sm hover:translate-x-[-1px] hover:translate-y-[-1px] hover:brutalist-shadow active:translate-x-[1px] active:translate-y-[1px] cursor-pointer"
          >
            {mobileMenuOpen ? (
              <X size={20} className="stroke-[3]" />
            ) : (
              <Menu size={20} className="stroke-[3]" />
            )}
          </button>
        </div>

        {/* Mobile Dropdown Menu */}
        <AnimatePresence>
          {mobileMenuOpen && (
            <motion.div
              initial={{ opacity: 0, y: -20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              className="absolute top-[100%] left-0 right-0 bg-white border-b-4 border-black brutalist-shadow-lg p-6 flex flex-col gap-4 md:hidden z-40"
            >
              <nav className="flex flex-col gap-3 text-sm font-black uppercase text-black">
                <a 
                  href="#features" 
                  onClick={() => setMobileMenuOpen(false)}
                  className="hover:bg-gray-100 p-2 brutalist-border"
                >
                  How It Works
                </a>
                <a 
                  href="#bento" 
                  onClick={() => setMobileMenuOpen(false)}
                  className="hover:bg-gray-100 p-2 brutalist-border"
                >
                  Features
                </a>
                <a 
                  href="#workers" 
                  onClick={() => setMobileMenuOpen(false)}
                  className="hover:bg-gray-100 p-2 brutalist-border"
                >
                  For Workers
                </a>
                <a 
                  href="#calculator" 
                  onClick={() => setMobileMenuOpen(false)}
                  className="hover:bg-gray-100 p-2 brutalist-border"
                >
                  Calculator
                </a>
                <a 
                  href="/admin" 
                  onClick={() => setMobileMenuOpen(false)}
                  className="hover:bg-gray-100 p-2 brutalist-border text-red-600"
                >
                  Admin Panel
                </a>
              </nav>

              <div className="flex flex-col gap-2 pt-2 border-t-2 border-dashed border-black">
                <a
                  href="/admin"
                  onClick={() => setMobileMenuOpen(false)}
                  className="brutalist-button text-xs uppercase py-3 text-center flex items-center justify-center gap-1.5"
                >
                  Admin Panel <ShieldCheck size={14} className="stroke-[3]" />
                </a>
                <a
                  href="#download"
                  onClick={() => setMobileMenuOpen(false)}
                  className="brutalist-button text-xs uppercase py-3 text-center flex items-center justify-center gap-1.5"
                >
                  Get App <ArrowRight size={14} className="stroke-[3]" />
                </a>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </header>

      {/* HERO SECTION */}
      <section className="relative z-10 max-w-7xl mx-auto px-6 pt-36 pb-20 md:pt-44 md:pb-28 grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
        <div className="lg:col-span-7 flex flex-col items-start text-left space-y-6">
          <div className="inline-flex items-center gap-2 px-3 py-1.5 bg-white brutalist-border text-xs font-black uppercase brutalist-shadow-sm">
            <span className="flex h-3.5 w-3.5 brutalist-border rounded-full bg-[#FFE600]" />
            India's First AI Hyperlocal Skill Marketplace
          </div>

          <h1 className="font-display text-4xl sm:text-5xl lg:text-7xl font-black tracking-tight leading-[1.0] uppercase text-black">
            JAHAN HAR <span className="bg-white px-2 brutalist-border inline-block rotate-[-1deg]">HUNAR</span> KI <br />
            <span className="bg-black text-[#FFE600] px-3 py-1 mt-2 inline-block brutalist-border rotate-[1deg] brutalist-shadow">VALUE</span> HAI.
          </h1>

          <p className="text-black text-sm sm:text-base max-w-xl font-bold leading-relaxed">
            HunarLoop digitizes and empowers informal skilled workers. Book verified local tutors, painters, mehendi artists, plumbers, cooks, and 100+ services. Direct bookings, live demo calls, and secure escrow payments.
          </p>

          {/* Download Badges */}
          <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-4 pt-4 w-full sm:w-auto">
            <button className="brutalist-button bg-black text-[#FFE600] hover:bg-black/90 font-black px-6 py-4 rounded-none flex items-center justify-center gap-3">
              <Smartphone size={24} className="stroke-[2.5]" />
              <div className="text-left">
                <span className="block text-[8px] uppercase tracking-wider opacity-85">Download for</span>
                <span className="text-sm font-black uppercase">Android & iOS</span>
              </div>
            </button>
            <div className="flex items-center gap-3 justify-center sm:justify-start py-2.5 px-4 bg-white brutalist-border brutalist-shadow-sm rounded-none">
              <div className="flex -space-x-2">
                <div className="w-8 h-8 rounded-full brutalist-border bg-[#FFE600] flex items-center justify-center text-[10px] font-black">S</div>
                <div className="w-8 h-8 rounded-full brutalist-border bg-white flex items-center justify-center text-[10px] font-black">P</div>
                <div className="w-8 h-8 rounded-full brutalist-border bg-black text-[#FFE600] flex items-center justify-center text-[10px] font-black">A</div>
              </div>
              <div className="text-xs text-left font-black uppercase">
                <span className="block">5,200+ Verified Workers</span>
                <span className="text-gray-600 text-[9px]">Onboarded in Lucknow Phase 1</span>
              </div>
            </div>
          </div>
        </div>

        {/* Live Matching Visual Widget */}
        <div className="lg:col-span-5 relative w-full flex justify-center">
          <div className="w-full max-w-[420px] bg-white brutalist-border p-6 brutalist-shadow-lg rounded-none">
            <div className="flex justify-between items-center border-b-3 border-black pb-4 mb-4">
              <span className="text-xs font-black text-black tracking-wider uppercase flex items-center gap-1.5">
                <Sparkles size={14} className="text-black stroke-[3]" /> Hyperlocal Match Engine
              </span>
              <span className="text-[10px] font-mono font-bold bg-[#FFE600] px-1.5 py-0.5 brutalist-border-bottom">v1.0.2</span>
            </div>

            {/* Simulated AI Search Panel */}
            <div className="bg-black text-[#FFE600] rounded-none p-4 brutalist-border relative min-h-[140px] flex flex-col justify-between">
              <div className="space-y-3">
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded-full bg-[#FFE600] animate-ping" />
                  <span className="text-[10px] font-mono font-black uppercase">STATUS: ACTIVE MATCHING</span>
                </div>
                <div className="h-[48px] flex items-center">
                  <AnimatePresence mode="wait">
                    <motion.p
                      key={matchingStep}
                      initial={{ opacity: 0, y: 5 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -5 }}
                      transition={{ duration: 0.3 }}
                      className="text-xs sm:text-sm font-mono font-black uppercase text-white"
                    >
                      {matchingScenarios[matchingStep].text}
                    </motion.p>
                  </AnimatePresence>
                </div>
              </div>

              {/* Progress bars indicator */}
              <div className="grid grid-cols-4 gap-1.5 mt-4">
                {matchingScenarios.map((_, index) => (
                  <div
                    key={index}
                    className={`h-2 transition-all duration-500 brutalist-border ${
                      index <= matchingStep ? "bg-[#FFE600]" : "bg-black"
                    }`}
                  />
                ))}
              </div>
            </div>

            {/* Demo Match Profile View */}
            <div className="mt-5 p-3 bg-[#FFE600] brutalist-border flex items-center gap-3">
              <div className="w-12 h-12 brutalist-border bg-white flex items-center justify-center">
                <User size={24} className="stroke-[2.5] text-black" />
              </div>
              <div className="flex-1">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-black uppercase text-black">Sunil Kumar</span>
                  <div className="bg-black text-[#FFE600] px-2 py-0.5 text-[9px] font-black brutalist-border">
                    Hunar: 94
                  </div>
                </div>
                <div className="flex items-center gap-2 mt-1">
                  <span className="text-[10px] font-bold uppercase text-black flex items-center gap-0.5">
                    <MapPin size={10} className="stroke-[2.5]" /> Hazratganj, 1.5km
                  </span>
                  <span className="text-[10px] bg-white text-black font-black uppercase px-1.5 brutalist-border">
                    ✓ Verified
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* INFINITE SERVICE SCROLL (CATEGORIES) */}
      <section className="bg-white border-y-4 border-black py-6 overflow-hidden relative w-full">
        <div className="max-w-7xl mx-auto px-6 mb-3 text-left">
          <p className="text-xs font-black uppercase tracking-wider text-black">100+ Skills Available - Direct Bookings</p>
        </div>
        <div className="flex gap-4 animate-scroll whitespace-nowrap px-4 py-1">
          {CATEGORIES.concat(CATEGORIES).map((cat, i) => {
            const IconComponent = cat.icon;
            return (
              <div
                key={i}
                className="inline-flex items-center gap-2 px-5 py-3 bg-white brutalist-border brutalist-shadow-sm hover:translate-y-[-1px] transition-transform cursor-default"
              >
                <div className={`p-1.5 brutalist-border ${cat.color} flex items-center justify-center`}>
                  <IconComponent size={16} className="text-black stroke-[3]" />
                </div>
                <span className="text-xs font-black uppercase text-black">{cat.name}</span>
              </div>
            );
          })}
        </div>

        <style jsx global>{`
          @keyframes scroll {
            0% { transform: translateX(0); }
            100% { transform: translateX(-50%); }
          }
          .animate-scroll {
            display: flex;
            width: max-content;
            animation: scroll 35s linear infinite;
          }
          .animate-scroll:hover {
            animation-play-state: paused;
          }
        `}</style>
      </section>

      {/* HOW IT WORKS SECTION */}
      <section id="features" className="max-w-7xl mx-auto px-6 py-20 text-center">
        <div className="space-y-4 max-w-xl mx-auto mb-16">
          <h2 className="font-display text-3xl sm:text-5xl font-black uppercase tracking-tight">
            How <span className="bg-black text-[#FFE600] px-2 brutalist-border">HunarLoop</span> Works
          </h2>
          <p className="text-black text-xs sm:text-sm font-bold uppercase">
            Empowering customers to find trusted talent and helping gig workers manage bookings in 3 simple steps.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 relative">
          {/* Step 1 */}
          <div className="bg-white brutalist-border p-8 text-left space-y-4 brutalist-shadow">
            <div className="w-12 h-12 bg-[#FFE600] brutalist-border flex items-center justify-center font-black text-lg">
              01
            </div>
            <h3 className="font-display text-lg font-black uppercase text-black">Search & Discover</h3>
            <p className="text-gray-800 text-xs sm:text-sm font-bold leading-relaxed">
              Open the app and search for a service. Our smart AI ranks nearby workers based on location, budget, availability, and their verified Hunar Score.
            </p>
          </div>

          {/* Step 2 */}
          <div className="bg-white brutalist-border p-8 text-left space-y-4 brutalist-shadow">
            <div className="w-12 h-12 bg-white brutalist-border flex items-center justify-center font-black text-lg">
              02
            </div>
            <h3 className="font-display text-lg font-black uppercase text-black">Live Video & Booking</h3>
            <p className="text-gray-800 text-xs sm:text-sm font-bold leading-relaxed">
              Verify credentials via a 2-minute live video call before making a booking. Schedule a slot directly onto the worker's integrated real-time calendar.
            </p>
          </div>

          {/* Step 3 */}
          <div className="bg-white brutalist-border p-8 text-left space-y-4 brutalist-shadow">
            <div className="w-12 h-12 bg-black text-[#FFE600] brutalist-border flex items-center justify-center font-black text-lg">
              03
            </div>
            <h3 className="font-display text-lg font-black uppercase text-black">Escrow Payout</h3>
            <p className="text-gray-800 text-xs sm:text-sm font-bold leading-relaxed">
              Funds are held in secure escrow upon booking. Once the job is completed and approved, payment is instantly routed to the worker's UPI ID.
            </p>
          </div>
        </div>
      </section>

      {/* BENTO GRID FEATURES SECTION */}
      <section id="bento" className="max-w-7xl mx-auto px-6 py-8">
        <div className="space-y-4 max-w-xl mx-auto mb-16 text-center">
          <h2 className="font-display text-3xl sm:text-5xl font-black uppercase tracking-tight">
            Designed For <span className="bg-white px-2 brutalist-border">Premium</span> Trust
          </h2>
          <p className="text-black text-xs sm:text-sm font-bold uppercase">
            Explore the cutting-edge features that set HunarLoop apart from legacy directory services.
          </p>
        </div>

        {/* Bento Grid Layout */}
        <div className="grid grid-cols-1 md:grid-cols-12 gap-6">
          
          {/* Card 1: AI Skill Verification (6 cols) */}
          <div className="md:col-span-7 bg-white brutalist-border p-6 relative overflow-hidden flex flex-col justify-between brutalist-shadow min-h-[300px]">
            <div className="flex justify-between items-start">
              <div className="w-10 h-10 bg-[#FFE600] brutalist-border flex items-center justify-center">
                <Video size={20} className="stroke-[3]" />
              </div>
              <span className="text-[10px] uppercase font-black bg-black text-[#FFE600] px-2.5 py-1 brutalist-border">
                AI Driven
              </span>
            </div>
            <div className="space-y-2 mt-6">
              <h3 className="font-display text-lg font-black uppercase text-black flex items-center gap-1.5">
                AI Skill Video Analysis
              </h3>
              <p className="text-gray-800 text-xs sm:text-sm font-bold leading-relaxed max-w-md">
                Workers upload a 60-second video displaying their work. Google Gemini AI evaluates the skill proficiency, giving an automated score that forms the bedrock of their verified profile badge.
              </p>
            </div>
            <div className="mt-6 brutalist-border bg-[#FFE600] p-3 flex items-center gap-3">
              <div className="relative w-12 h-12 bg-white brutalist-border flex items-center justify-center">
                <Video size={22} className="stroke-[2.5]" />
                <span className="absolute bottom-0 right-0 text-[7px] bg-black text-white px-0.5 font-mono">0:45</span>
              </div>
              <div className="flex-1">
                <p className="text-[9px] font-black uppercase text-black">AI analyzing sample plumbing task...</p>
                <div className="w-full bg-white h-3 brutalist-border mt-1.5 overflow-hidden">
                  <div className="bg-black h-full w-[85%]" />
                </div>
              </div>
              <span className="text-[10px] font-black uppercase bg-white px-1.5 brutalist-border">92% MATCH</span>
            </div>
          </div>

          {/* Card 2: Hunar Score (5 cols) */}
          <div className="md:col-span-5 bg-white brutalist-border p-6 relative overflow-hidden flex flex-col justify-between brutalist-shadow min-h-[300px]">
            <div className="w-10 h-10 bg-black text-[#FFE600] brutalist-border flex items-center justify-center">
              <Shield size={20} className="stroke-[2.5]" />
            </div>
            <div className="space-y-2 mt-6">
              <h3 className="font-display text-lg font-black uppercase text-black">Hunar Score Trust System</h3>
              <p className="text-gray-800 text-xs sm:text-sm font-bold leading-relaxed">
                A single rating out of 100 based on core parameters: star rating average (40%), booking response time (15%), job completion rate (25%), and AI video analysis (20%).
              </p>
            </div>
            {/* Trust system breakdown display */}
            <div className="grid grid-cols-2 gap-2 mt-6 text-[9px] font-black uppercase">
              <div className="p-2 bg-[#FFE600] brutalist-border">
                <span className="block text-gray-700">Star Ratings</span>
                <span className="font-black text-black">40% Weight</span>
              </div>
              <div className="p-2 bg-[#FFE600] brutalist-border">
                <span className="block text-gray-700">Completion</span>
                <span className="font-black text-black">25% Weight</span>
              </div>
              <div className="p-2 bg-[#FFE600] brutalist-border">
                <span className="block text-gray-700">AI Video</span>
                <span className="font-black text-black">20% Weight</span>
              </div>
              <div className="p-2 bg-[#FFE600] brutalist-border">
                <span className="block text-gray-700">Response</span>
                <span className="font-black text-black">15% Weight</span>
              </div>
            </div>
          </div>

          {/* Card 3: Live Skill Demo (5 cols) */}
          <div className="md:col-span-5 bg-white brutalist-border p-6 relative overflow-hidden flex flex-col justify-between brutalist-shadow min-h-[300px]">
            <div className="w-10 h-10 bg-[#FFE600] brutalist-border flex items-center justify-center">
              <Video size={20} className="stroke-[3]" />
            </div>
            <div className="space-y-2 mt-6">
              <h3 className="font-display text-lg font-black uppercase text-black">2-Min Live Skill Demo</h3>
              <p className="text-gray-800 text-xs sm:text-sm font-bold leading-relaxed">
                Reduce booking cancellations and establish instant trust. Customers can request a secure 2-minute video call to inspect toolsets or review specific requirements.
              </p>
            </div>
            {/* Simulated Live Demo screen UI */}
            <div className="mt-6 brutalist-border bg-black p-3 flex items-center justify-between text-[#FFE600]">
              <div className="flex items-center gap-2">
                <div className="w-2.5 h-2.5 rounded-full bg-red-500 animate-pulse" />
                <span className="text-[9px] font-black font-mono">LIVE DEMO CALL</span>
              </div>
              <span className="text-[9px] font-mono bg-white text-black px-1.5 font-bold">01:54 remaining</span>
            </div>
          </div>

          {/* Card 4: Escrow Protection & Gifting (7 cols) */}
          <div className="md:col-span-7 bg-white brutalist-border p-6 relative overflow-hidden flex flex-col justify-between brutalist-shadow min-h-[300px]">
            <div className="flex justify-between items-start">
              <div className="w-10 h-10 bg-black text-[#FFE600] brutalist-border flex items-center justify-center">
                <Lock size={20} className="stroke-[2.5]" />
              </div>
              <span className="text-[10px] font-black uppercase bg-[#FFE600] text-black px-2.5 py-1 brutalist-border">
                100% Secure
              </span>
            </div>
            <div className="space-y-2 mt-6">
              <h3 className="font-display text-lg font-black uppercase text-black">Escrow Protection & Gifting</h3>
              <p className="text-gray-800 text-xs sm:text-sm font-bold leading-relaxed">
                Payments made upfront are securely held in Razorpay escrow. Release is triggered automatically by the customer or via a 24-hour completion timer. Plus, purchase custom skill gift cards to share with friends and family.
              </p>
            </div>
            <div className="grid grid-cols-3 gap-2 mt-6 text-[9px] text-center font-black uppercase">
              <div className="p-3 bg-[#FFE600] brutalist-border flex flex-col items-center justify-center">
                <Coins size={16} className="text-black mb-1 stroke-[2.5]" />
                <span>Escrow Safe</span>
              </div>
              <div className="p-3 bg-[#FFE600] brutalist-border flex flex-col items-center justify-center">
                <Calendar size={16} className="text-black mb-1 stroke-[2.5]" />
                <span>Subscriptions</span>
              </div>
              <div className="p-3 bg-[#FFE600] brutalist-border flex flex-col items-center justify-center">
                <Sparkles size={16} className="text-black mb-1 stroke-[2.5]" />
                <span>Gift Cards</span>
              </div>
            </div>
          </div>

        </div>
      </section>

      {/* WORKER BENEFIT / INCOME CALCULATOR SECTION */}
      <section id="workers" className="border-t-4 border-black bg-white py-20 relative">
        <div className="max-w-7xl mx-auto px-6 grid grid-cols-1 lg:grid-cols-12 gap-12 items-center relative z-10">
          
          <div className="lg:col-span-5 space-y-6">
            <span className="text-xs font-black uppercase tracking-wider bg-[#FFE600] px-2 py-1 brutalist-border inline-block">For Skilled Professionals</span>
            <h2 className="font-display text-3xl sm:text-5xl font-black uppercase tracking-tight text-black">
              Double Earnings. <br />
              Become a <span className="bg-black text-[#FFE600] px-2.5 py-0.5 inline-block rotate-[-1deg] brutalist-border">Partner</span>.
            </h2>
            <p className="text-gray-800 text-xs sm:text-sm font-bold leading-relaxed">
              Legacy agencies take 30% to 40% commission, and unorganized listings offer no security. HunarLoop charges a flat 10% platform fee, gives you a verified digital identity, and provides instant payouts straight to your UPI.
            </p>

            {/* Benefits points */}
            <div className="space-y-4 text-xs font-black uppercase">
              <div className="flex items-center gap-3">
                <CheckCircle size={18} className="text-black stroke-[3]" />
                <span>Escrow protection — no missed payments</span>
              </div>
              <div className="flex items-center gap-3">
                <CheckCircle size={18} className="text-black stroke-[3]" />
                <span>Hunar Skill certification courses to boost rates</span>
              </div>
              <div className="flex items-center gap-3">
                <CheckCircle size={18} className="text-black stroke-[3]" />
                <span>Flexible hours — toggle availability when online</span>
              </div>
            </div>
          </div>

          {/* Income Calculator Widget */}
          <div id="calculator" className="lg:col-span-7 bg-white brutalist-border p-6 md:p-8 brutalist-shadow-lg">
            <h3 className="font-display text-lg font-black uppercase text-black mb-6 flex items-center justify-between border-b-3 border-black pb-4">
              <span>HunarLoop Earnings Calculator</span>
              <span className="text-[10px] font-mono bg-black text-[#FFE600] px-2 py-0.5 brutalist-border">90% Payout</span>
            </h3>

            {/* Skill selection row */}
            <div className="mb-6">
              <span className="block text-[10px] text-gray-700 font-black mb-3 uppercase tracking-wider">Select Skill Preset</span>
              <div className="flex flex-wrap gap-2">
                {SKILL_PRESETS.map((preset) => (
                  <button
                    key={preset.name}
                    onClick={() => handleSkillPresetChange(preset.name, preset.rate)}
                    className={`px-4 py-2 text-xs font-black uppercase transition-all brutalist-border ${
                      selectedSkill === preset.name
                        ? "bg-black text-[#FFE600]"
                        : "bg-[#FFE600] text-black hover:bg-yellow-300"
                    }`}
                  >
                    {preset.name}
                  </button>
                ))}
              </div>
            </div>

            {/* Hourly Rate Slider */}
            <div className="space-y-3 mb-6">
              <div className="flex justify-between text-xs font-black uppercase">
                <span className="text-gray-700">YOUR HOURLY RATE</span>
                <span className="bg-black text-[#FFE600] px-1.5 brutalist-border">₹{hourlyRate} / hour</span>
              </div>
              <input
                type="range"
                min="150"
                max="1500"
                step="25"
                value={hourlyRate}
                onChange={(e) => setHourlyRate(Number(e.target.value))}
                className="w-full h-3 bg-[#FFE600] brutalist-border appearance-none cursor-pointer accent-black"
              />
              <div className="flex justify-between text-[10px] font-black uppercase text-gray-600">
                <span>₹150</span>
                <span>₹1,500</span>
              </div>
            </div>

            {/* Hours per Week Slider */}
            <div className="space-y-3 mb-8">
              <div className="flex justify-between text-xs font-black uppercase">
                <span className="text-gray-700">ESTIMATED HOURS / WEEK</span>
                <span className="bg-black text-[#FFE600] px-1.5 brutalist-border">{hoursPerWeek} hours</span>
              </div>
              <input
                type="range"
                min="5"
                max="60"
                step="1"
                value={hoursPerWeek}
                onChange={(e) => setHoursPerWeek(Number(e.target.value))}
                className="w-full h-3 bg-[#FFE600] brutalist-border appearance-none cursor-pointer accent-black"
              />
              <div className="flex justify-between text-[10px] font-black uppercase text-gray-600">
                <span>5 hours</span>
                <span>60 hours</span>
              </div>
            </div>

            {/* Display Output Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 border-t-3 border-black pt-6">
              <div className="p-4 bg-[#FFE600] brutalist-border text-left">
                <span className="text-[10px] text-gray-700 font-black uppercase block mb-1">Total Monthly Bookings</span>
                <span className="text-2xl font-black text-black font-mono">₹{calculatedMonthly.toLocaleString("en-IN")}</span>
              </div>
              <div className="p-4 bg-black text-[#FFE600] brutalist-border text-left">
                <span className="text-[10px] text-[#FFE600] font-black uppercase block flex items-center gap-1 mb-1">
                  Your Net Earnings <Info size={12} className="stroke-[2.5]" />
                </span>
                <span className="text-2xl font-black text-white font-mono">₹{netEarnings.toLocaleString("en-IN")}</span>
                <span className="block text-[8px] text-[#FFE600]/80 font-black mt-1 uppercase">
                  After 10% Platform Fee (₹{platformFee.toLocaleString("en-IN")})
                </span>
              </div>
            </div>

            <div className="mt-6 text-center">
              <button className="brutalist-button text-xs uppercase w-full py-4 rounded-none">
                Register as a HunarLoop Worker Partner
              </button>
            </div>

          </div>

        </div>
      </section>

      {/* FAQS SECTION */}
      <section className="max-w-4xl mx-auto px-6 py-20">
        <h2 className="font-display text-3xl sm:text-5xl font-black uppercase tracking-tight text-center mb-12">
          Frequently Asked Questions
        </h2>

        <div className="space-y-4">
          {[
            {
              q: "How does HunarLoop verify worker skills?",
              a: "HunarLoop enforces verification through a unique combination of AI analysis and mandatory documentation. Workers upload a 60-second video demo showing their skill in action. Our AI (Google Gemini) reviews and scores this video, which is then paired with Aadhaar KYC checking to unlock their verified profile badge."
            },
            {
              q: "How does the Escrow Payment system protect me?",
              a: "When you book a service, your payment is secure. HunarLoop holds the money in escrow. The payment is only released to the worker once you mark the job as completed successfully, or automatically after 24 hours if there are no disputes raised."
            },
            {
              q: "What happens if there is a dispute during a job?",
              a: "If a job is not completed to your satisfaction, you can raise a dispute in the app within the 24-hour completion window. HunarLoop's support team reviews the chat logs, project description photos, and works with both parties to resolve the payout fairly."
            },
            {
              q: "Is there any charge for workers to join?",
              a: "Joining HunarLoop and setting up your digital portfolio is entirely free. We only charge a flat 10% platform commission on completed and paid bookings. There are no paid listing fees or hidden charges."
            }
          ].map((faq, index) => (
            <div
              key={index}
              className="bg-white brutalist-border rounded-none overflow-hidden transition-colors"
            >
              <button
                onClick={() => setOpenFaq(openFaq === index ? null : index)}
                className="w-full p-5 flex items-center justify-between text-left font-black text-xs sm:text-sm uppercase text-black hover:bg-[#FFE600] transition-colors focus:outline-none"
              >
                <span>{faq.q}</span>
                {openFaq === index ? <ChevronUp size={18} className="stroke-[2.5]" /> : <ChevronDown size={18} className="stroke-[2.5]" />}
              </button>
              
              <AnimatePresence initial={false}>
                {openFaq === index && (
                  <motion.div
                    initial={{ height: 0 }}
                    animate={{ height: "auto" }}
                    exit={{ height: 0 }}
                    transition={{ duration: 0.2 }}
                    className="overflow-hidden bg-[#FFE600]/20 border-t-3 border-black"
                  >
                    <div className="p-5 text-gray-800 text-xs sm:text-sm font-bold leading-relaxed">
                      {faq.a}
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          ))}
        </div>
      </section>

      {/* DOWNLOAD / CTA SECTION */}
      <section id="download" className="max-w-7xl mx-auto px-6 pb-12">
        <div className="bg-white brutalist-border p-8 md:p-12 relative overflow-hidden flex flex-col md:flex-row items-center justify-between gap-8 brutalist-shadow-lg">
          <div className="space-y-4 max-w-xl text-left relative z-10">
            <h2 className="font-display text-2xl sm:text-4xl font-black uppercase tracking-tight">
              Ready to find trusted talent near you?
            </h2>
            <p className="text-black text-xs sm:text-sm font-bold">
              Get the mobile app today. Create a customer profile, browse hundreds of verified local workers, view live skill demo video calls, and book securely in minutes.
            </p>
            <div className="flex gap-4 pt-2">
              <button className="brutalist-button text-xs uppercase px-5 py-3 rounded-none">
                Play Store (Android)
              </button>
              <button className="bg-white border-3 border-black text-black font-black uppercase text-xs px-5 py-3 rounded-none brutalist-shadow-sm hover:translate-y-[-1px] transition-transform">
                App Store (iOS)
              </button>
            </div>
          </div>

          <div className="relative flex justify-center w-full max-w-[200px] md:max-w-[260px]">
            {/* Simple simulated QR code box */}
            <div className="p-4 bg-white brutalist-border text-center flex flex-col items-center rounded-none brutalist-shadow-sm">
              <div className="w-36 h-36 bg-black rounded-none flex flex-col items-center justify-center font-bold text-[7px] text-[#FFE600]">
                <Shield size={24} className="mb-2 stroke-[2.5]" />
                <span className="font-mono">HUNARLOOP SCAN</span>
              </div>
              <span className="block text-[8px] text-black font-black uppercase mt-2.5">SCAN TO DOWNLOAD APP</span>
            </div>
          </div>
        </div>
      </section>

      {/* FOOTER */}
      <footer className="border-t-4 border-black bg-white py-12 px-6">
        <div className="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-4 gap-8 mb-8">
          <div className="space-y-4">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 brutalist-border bg-[#FFE600] flex items-center justify-center font-black text-sm text-black">
                HL
              </div>
              <span className="font-display text-xl font-black text-black uppercase tracking-tight">
                HunarLoop
              </span>
            </div>
            <p className="text-gray-800 text-xs font-bold leading-relaxed">
              India's first AI-powered hyperlocal skill marketplace. Giving informal skilled workers a verified digital identity and customers secure bookings.
            </p>
          </div>

          <div>
            <span className="block text-[10px] font-black text-black mb-4 uppercase tracking-wider border-b-3 border-black pb-1">Features</span>
            <ul className="space-y-2.5 text-xs font-bold uppercase text-gray-700">
              <li><a href="#bento" className="hover:underline">AI Skill Video Analysis</a></li>
              <li><a href="#bento" className="hover:underline">Hunar Score Trust System</a></li>
              <li><a href="#bento" className="hover:underline">Live Video Skill Demos</a></li>
              <li><a href="#bento" className="hover:underline">Escrow Protection Payments</a></li>
            </ul>
          </div>

          <div>
            <span className="block text-[10px] font-black text-black mb-4 uppercase tracking-wider border-b-3 border-black pb-1">For Partners</span>
            <ul className="space-y-2.5 text-xs font-bold uppercase text-gray-700">
              <li><a href="#workers" className="hover:underline">Register as Worker</a></li>
              <li><a href="#calculator" className="hover:underline">Income Calculator</a></li>
              <li><a href="#workers" className="hover:underline">Platform Fees</a></li>
              <li><a href="#workers" className="hover:underline">Skill Upgrading Courses</a></li>
            </ul>
          </div>

          <div>
            <span className="block text-[10px] font-black text-black mb-4 uppercase tracking-wider border-b-3 border-black pb-1">Company</span>
            <p className="text-xs font-bold uppercase text-gray-800 leading-relaxed mb-3">
              Office: Hazratganj, Lucknow, Uttar Pradesh, India.
            </p>
            <p className="text-xs font-bold uppercase text-gray-800 leading-relaxed">
              Email: support@hunarloop.in
            </p>
          </div>
        </div>

        <div className="max-w-7xl mx-auto border-t-3 border-black pt-6 flex flex-col md:flex-row items-center justify-between text-[10px] font-black uppercase text-gray-700 gap-4">
          <p>© 2026 HunarLoop Private Limited. All rights reserved. Confidential & Proprietary.</p>
          <div className="flex gap-6">
            <a
              href="/privacy"
              onClick={(e) => {
                e.preventDefault();
                setActivePolicy("privacy");
              }}
              className="hover:underline"
            >
              Privacy Policy
            </a>
            <a
              href="/terms"
              onClick={(e) => {
                e.preventDefault();
                setActivePolicy("terms");
              }}
              className="hover:underline"
            >
              Terms of Service
            </a>
            <a
              href="/refund"
              onClick={(e) => {
                e.preventDefault();
                setActivePolicy("refund");
              }}
              className="hover:underline"
            >
              Refund Policy
            </a>
          </div>
        </div>
      </footer>

      {/* SCROLL TO TOP BUTTON */}
      {showScrollTop && (
        <button
          onClick={() => window.scrollTo({ top: 0, behavior: "smooth" })}
          className="fixed bottom-6 right-6 w-12 h-12 bg-white brutalist-border brutalist-shadow text-black flex items-center justify-center cursor-pointer hover:bg-[#FFE600] active:translate-x-1 active:translate-y-1 transition-all z-50 font-black text-xl"
        >
          ↑
        </button>
      )}

      {/* POLICY MODAL POPUP */}
      <AnimatePresence>
        {activePolicy && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-black/60 backdrop-blur-sm z-[100] flex items-center justify-center p-4"
          >
            <motion.div
              initial={{ scale: 0.9, y: 20 }}
              animate={{ scale: 1, y: 0 }}
              exit={{ scale: 0.9, y: 20 }}
              className="bg-white border-4 border-black brutalist-shadow-lg max-w-2xl w-full max-h-[85vh] flex flex-col relative"
            >
              {/* Modal Header */}
              <div className="bg-[#FFE600] border-b-4 border-black p-5 flex items-center justify-between">
                <div>
                  <h3 className="font-display text-xl sm:text-2xl font-black uppercase text-black tracking-tight">
                    {policyContent[activePolicy].title}
                  </h3>
                  <span className="block text-[8px] sm:text-[9px] font-black uppercase tracking-wider text-black/70 mt-0.5">
                    LAST UPDATED: {policyContent[activePolicy].updated}
                  </span>
                </div>
                <button
                  onClick={() => setActivePolicy(null)}
                  className="bg-white border-3 border-black text-black font-black uppercase text-xs px-3 py-1.5 rounded-none brutalist-shadow-sm hover:bg-black hover:text-[#FFE600] transition-colors focus:outline-none"
                >
                  CLOSE
                </button>
              </div>

              {/* Modal Body */}
              <div className="p-6 overflow-y-auto space-y-6 bg-[#FFE600]/5 text-black text-xs sm:text-sm font-bold leading-relaxed flex-1">
                {policyContent[activePolicy].sections.map((section, idx) => (
                  <div key={idx} className="space-y-2">
                    <h4 className="font-black text-sm uppercase tracking-wide border-b-2 border-black/20 pb-1">
                      {section.title}
                    </h4>
                    <p className="text-gray-800 uppercase font-bold text-xs">
                      {section.content}
                    </p>
                  </div>
                ))}
              </div>

              {/* Modal Footer */}
              <div className="border-t-4 border-black p-4 bg-white flex justify-end">
                <button
                  onClick={() => setActivePolicy(null)}
                  className="brutalist-button px-6 py-3 text-xs uppercase"
                >
                  I UNDERSTAND & AGREE
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

    </div>
  );
}
