"use client";

import React, { useState, useEffect } from "react";
import { db } from "@/lib/firebase";
import { collection, onSnapshot, doc, updateDoc, deleteDoc } from "firebase/firestore";
import { motion, AnimatePresence } from "framer-motion";
import { 
  ShieldCheck, 
  XCircle, 
  Check, 
  X, 
  Eye, 
  Users,
  Search,
  Trash2,
  UserCheck,
  UserX,
  HelpCircle,
  LogOut,
  Lock,
  MessageSquare,
  Activity,
  Mail,
  Phone,
  FileText
} from "lucide-react";

interface UserData {
  uid: string;
  name: string;
  email: string;
  phone: string;
  role: "worker" | "customer";
  category?: string;
  skills?: string[];
  idType?: string;
  idNumber?: string;
  idCardPhoto?: string;
  idCardPhotoBack?: string;
  verificationStatus?: string; // 'none', 'pending', 'approved', 'rejected'
  isVerified?: boolean;
  rating?: string;
  hunarScore?: number;
  isDisabled?: boolean;
  address?: string;
  preferredContact?: string;
  preferredSlot?: string;
}

interface SupportTicket {
  ticketId: string;
  uid: string;
  name: string;
  role: string;
  message: string;
  adminReply?: string;
  status: "open" | "resolved";
  timestamp?: any;
}

export default function AdminPanel() {
  // Authentication State
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [adminEmail, setAdminEmail] = useState("");
  const [adminPassword, setAdminPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loginError, setLoginError] = useState("");
  const [mounted, setMounted] = useState(false);

  // Data States
  const [users, setUsers] = useState<UserData[]>([]);
  const [tickets, setTickets] = useState<SupportTicket[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedTab, setSelectedTab] = useState<"verification" | "workers" | "customers" | "support">("verification");
  const [selectedPhoto, setSelectedPhoto] = useState<string | null>(null);

  // Ticket Resolution state
  const [replyTexts, setReplyTexts] = useState<Record<string, string>>({});

  // Check Session on Mount
  useEffect(() => {
    setMounted(true);
    const session = localStorage.getItem("hunar_admin_session") || sessionStorage.getItem("hunar_admin_session");
    if (session === "authenticated") {
      setIsLoggedIn(true);
    }
  }, []);

  // Fetch Users and Tickets
  useEffect(() => {
    if (!isLoggedIn) return;

    // Fetch Users
    const usersCol = collection(db, "users");
    const unsubscribeUsers = onSnapshot(usersCol, (snapshot) => {
      const usersList: UserData[] = [];
      snapshot.forEach((doc) => {
        const data = doc.data() as Omit<UserData, "uid">;
        usersList.push({
          uid: doc.id,
          ...data
        });
      });
      setUsers(usersList);
      setLoading(false);
    }, (error) => {
      console.error("Error fetching users:", error);
    });

    // Fetch Support Tickets
    const ticketsCol = collection(db, "support_tickets");
    const unsubscribeTickets = onSnapshot(ticketsCol, (snapshot) => {
      const ticketsList: SupportTicket[] = [];
      snapshot.forEach((doc) => {
        const data = doc.data() as Omit<SupportTicket, "ticketId">;
        ticketsList.push({
          ticketId: doc.id,
          ...data
        });
      });
      // Sort by timestamp descending
      ticketsList.sort((a, b) => {
        const timeA = a.timestamp?.seconds || 0;
        const timeB = b.timestamp?.seconds || 0;
        return timeB - timeA;
      });
      setTickets(ticketsList);
    }, (error) => {
      console.error("Error fetching support tickets:", error);
    });

    return () => {
      unsubscribeUsers();
      unsubscribeTickets();
    };
  }, [isLoggedIn]);

  // Login handler
  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    const cleanEmail = adminEmail.trim().toLowerCase();
    if (cleanEmail === "arpitsinghyadav56@gmail.com" && adminPassword === "Asus1432@569") {
      localStorage.setItem("hunar_admin_session", "authenticated");
      sessionStorage.setItem("hunar_admin_session", "authenticated");
      setIsLoggedIn(true);
      setLoginError("");
    } else {
      setLoginError("INVALID ADMIN EMAIL OR PASSWORD. ACCESS DENIED.");
    }
  };

  // Logout handler
  const handleLogout = () => {
    localStorage.removeItem("hunar_admin_session");
    sessionStorage.removeItem("hunar_admin_session");
    setIsLoggedIn(false);
    window.location.href = "/";
  };

  // e-KYC Verification Action Handlers
  const handleApprove = async (uid: string) => {
    try {
      const docRef = doc(db, "users", uid);
      await updateDoc(docRef, {
        verificationStatus: "approved",
        isVerified: true,
        hunarScore: 95
      });
      alert("User approved successfully!");
    } catch (e) {
      console.error(e);
      alert("Error approving user.");
    }
  };

  const handleReject = async (uid: string) => {
    try {
      const docRef = doc(db, "users", uid);
      await updateDoc(docRef, {
        verificationStatus: "rejected",
        isVerified: false,
        hunarScore: 90
      });
      alert("User rejected.");
    } catch (e) {
      console.error(e);
      alert("Error rejecting user.");
    }
  };

  const handleRevoke = async (uid: string) => {
    if (!confirm("Are you sure you want to revoke verification for this user?")) return;
    try {
      const docRef = doc(db, "users", uid);
      await updateDoc(docRef, {
        verificationStatus: "none",
        isVerified: false,
        hunarScore: 90
      });
      alert("Verification revoked.");
    } catch (e) {
      console.error(e);
      alert("Error revoking verification.");
    }
  };

  // Disable / Enable Account Handler
  const handleToggleDisable = async (uid: string, currentDisabled: boolean) => {
    const actionText = currentDisabled ? "enable" : "disable";
    if (!confirm(`Are you sure you want to ${actionText} this user's account?`)) return;
    try {
      const docRef = doc(db, "users", uid);
      await updateDoc(docRef, {
        isDisabled: !currentDisabled
      });
      alert(`User account ${!currentDisabled ? "DISABLED" : "ENABLED"} successfully!`);
    } catch (e) {
      console.error(e);
      alert("Error updating user status.");
    }
  };

  // Delete User Account Handler
  const handleDeleteUser = async (uid: string) => {
    if (!confirm("CRITICAL: Are you sure you want to permanently delete this user account? This action cannot be undone.")) return;
    try {
      // Set disabled first just in case to trigger UI overlay blocker
      const docRef = doc(db, "users", uid);
      await updateDoc(docRef, { isDisabled: true });
      await deleteDoc(docRef);
      alert("User account deleted successfully from database.");
    } catch (e) {
      console.error(e);
      alert("Error deleting user account.");
    }
  };

  // Help & Support Reply Handler
  const handleResolveTicket = async (ticketId: string) => {
    const reply = replyTexts[ticketId] || "";
    if (!reply.trim()) {
      alert("Please enter a response reply before resolving the ticket.");
      return;
    }
    try {
      const docRef = doc(db, "support_tickets", ticketId);
      await updateDoc(docRef, {
        adminReply: reply,
        status: "resolved"
      });
      alert("Reply sent! Ticket marked as resolved.");
      setReplyTexts(prev => ({ ...prev, [ticketId]: "" }));
    } catch (e) {
      console.error(e);
      alert("Error resolving support ticket.");
    }
  };

  // Compute Categories from Live User Data
  const workers = users.filter((u) => u.role === "worker");
  const customers = users.filter((u) => u.role === "customer");
  const openTicketsCount = tickets.filter((t) => t.status === "open").length;

  // Filter Workers/Customers based on tab & search query
  const getFilteredData = () => {
    const q = searchQuery.toLowerCase();
    if (selectedTab === "verification") {
      return users.filter(
        (u) =>
          (u.verificationStatus === "pending" || u.verificationStatus === "rejected" || u.verificationStatus === "approved") &&
          ((u.name || "").toLowerCase().includes(q) || (u.category || "").toLowerCase().includes(q) || (u.role || "").toLowerCase().includes(q))
      );
    } else if (selectedTab === "workers") {
      return workers.filter(
        (w) => (w.name || "").toLowerCase().includes(q) || (w.category || "").toLowerCase().includes(q)
      );
    } else if (selectedTab === "customers") {
      return customers.filter(
        (c) => (c.name || "").toLowerCase().includes(q) || (c.address || "").toLowerCase().includes(q)
      );
    } else {
      return tickets.filter(
        (t) => (t.name || "").toLowerCase().includes(q) || (t.message || "").toLowerCase().includes(q)
      );
    }
  };

  const filteredData = getFilteredData();

  // Render loading spinner until mounted to avoid hydration mismatch
  if (!mounted) {
    return (
      <div className="min-h-screen bg-[#FFE600] flex items-center justify-center p-6 font-sans">
        <div className="w-12 h-12 border-4 border-black border-t-[#FFE600] rounded-full animate-spin mx-auto"></div>
      </div>
    );
  }

  // LOGIN SCREEN
  if (!isLoggedIn) {
    return (
      <div className="min-h-screen bg-[#FFE600] flex items-center justify-center p-6 font-sans">
        <motion.div 
          initial={{ scale: 0.95, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          className="bg-white brutalist-border brutalist-shadow-lg p-8 max-w-md w-full"
        >
          <div className="text-center mb-6">
            <div className="w-16 h-16 bg-black text-[#FFE600] rounded-full flex items-center justify-center mx-auto mb-3 brutalist-border">
              <Lock className="w-8 h-8" />
            </div>
            <h1 className="text-3xl font-black tracking-tighter uppercase leading-none">ADMIN PORTAL</h1>
            <p className="text-xs font-bold uppercase mt-1 text-gray-500">Access Key Authentication Required</p>
          </div>

          <form onSubmit={handleLogin} className="space-y-4">
            <div>
              <label className="block text-[10px] font-black uppercase mb-1">Admin Email Address</label>
              <div className="relative brutalist-border bg-gray-50 flex items-center px-3">
                <Mail className="w-4 h-4 text-gray-500 mr-2" />
                 <input
                  type="email"
                  required
                  suppressHydrationWarning
                  placeholder="admin@hunarloop.in"
                  value={adminEmail}
                  onChange={(e) => setAdminEmail(e.target.value)}
                  className="py-3 bg-transparent font-bold w-full focus:outline-none text-sm text-black"
                />
              </div>
            </div>

            <div>
              <label className="block text-[10px] font-black uppercase mb-1">Access Password</label>
              <div className="relative brutalist-border bg-gray-50 flex items-center px-3">
                <Lock className="w-4 h-4 text-gray-500 mr-2" />
                 <input
                  type={showPassword ? "text" : "password"}
                  required
                  suppressHydrationWarning
                  placeholder="••••••••••••"
                  value={adminPassword}
                  onChange={(e) => setAdminPassword(e.target.value)}
                  className="py-3 bg-transparent font-bold w-full focus:outline-none text-sm text-black"
                />
                <button
                  type="button"
                  suppressHydrationWarning
                  onClick={() => setShowPassword(!showPassword)}
                  className="text-xs font-black text-gray-500 uppercase ml-2 hover:underline"
                >
                  {showPassword ? "Hide" : "Show"}
                </button>
              </div>
            </div>

            {loginError && (
              <div className="bg-red-500 text-white p-3 text-center text-xs font-black brutalist-border uppercase">
                {loginError}
              </div>
            )}

             <button
              type="submit"
              suppressHydrationWarning
              className="w-full bg-black text-[#FFE600] font-black text-sm py-4 brutalist-border brutalist-shadow-sm hover:translate-x-[-2px] hover:translate-y-[-2px] hover:brutalist-shadow transition-all uppercase cursor-pointer"
            >
              AUTHENTICATE ACCESS
            </button>
          </form>
        </motion.div>
      </div>
    );
  }

  // LOGGED IN DASHBOARD CONSOLE
  return (
    <div className="min-h-screen bg-[#FFE600] text-black font-sans pb-12">
      {/* Top Banner Header */}
      <header className="bg-black text-[#FFE600] border-b-4 border-black brutalist-shadow-sm py-6 px-8 sticky top-0 z-10 flex flex-col md:flex-row justify-between items-center gap-4">
        <div>
          <h1 className="text-3xl font-black tracking-tighter flex items-center gap-3">
            <ShieldCheck className="w-8 h-8 text-[#FFE600]" />
            HUNARLOOP ADMINISTRATIVE HEADQUARTERS
          </h1>
          <p className="text-xs font-bold uppercase mt-1 text-gray-400">
            Realtime trust scoring, user management, and e-KYC desk
          </p>
        </div>
        <div className="flex items-center gap-3">
          <div className="bg-[#FFE600] text-black px-4 py-2 brutalist-border font-black text-sm brutalist-shadow-sm">
            ADMIN: ARPIT SINGH YADAV
          </div>
          <button
            onClick={handleLogout}
            className="bg-red-500 text-white p-2.5 brutalist-border brutalist-shadow-sm hover:bg-red-600 transition-all flex items-center gap-1.5 font-black text-xs cursor-pointer"
          >
            <LogOut className="w-4 h-4" /> LOGOUT
          </button>
        </div>
      </header>

      {/* Main Container */}
      <main className="max-w-7xl mx-auto px-4 mt-8">
        
        {/* System Stats Row */}
        <section className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
          <div className="bg-white brutalist-border brutalist-shadow-sm p-4 flex items-center justify-between">
            <div>
              <span className="text-[10px] font-black text-gray-400 uppercase">Registered Workers</span>
              <h3 className="text-3xl font-black leading-none mt-1">{workers.length}</h3>
            </div>
            <div className="w-12 h-12 bg-blue-100 brutalist-border flex items-center justify-center">
              <Users className="w-6 h-6 text-blue-600" />
            </div>
          </div>

          <div className="bg-white brutalist-border brutalist-shadow-sm p-4 flex items-center justify-between">
            <div>
              <span className="text-[10px] font-black text-gray-400 uppercase">Registered Customers</span>
              <h3 className="text-3xl font-black leading-none mt-1">{customers.length}</h3>
            </div>
            <div className="w-12 h-12 bg-pink-100 brutalist-border flex items-center justify-center">
              <Users className="w-6 h-6 text-pink-600" />
            </div>
          </div>

          <div className="bg-white brutalist-border brutalist-shadow-sm p-4 flex items-center justify-between">
            <div>
              <span className="text-[10px] font-black text-gray-400 uppercase">Pending ID Reviews</span>
              <h3 className="text-3xl font-black leading-none mt-1">
                {users.filter(u => u.verificationStatus === "pending").length}
              </h3>
            </div>
            <div className="w-12 h-12 bg-orange-100 brutalist-border flex items-center justify-center">
              <FileText className="w-6 h-6 text-orange-600" />
            </div>
          </div>

          <div className="bg-white brutalist-border brutalist-shadow-sm p-4 flex items-center justify-between">
            <div>
              <span className="text-[10px] font-black text-gray-400 uppercase">Open Support Tickets</span>
              <h3 className="text-3xl font-black leading-none mt-1">{openTicketsCount}</h3>
            </div>
            <div className="w-12 h-12 bg-red-100 brutalist-border flex items-center justify-center">
              <MessageSquare className="w-6 h-6 text-red-600" />
            </div>
          </div>
        </section>

        {/* Search Bar & Tab Navigation */}
        <div className="flex flex-col md:flex-row gap-4 items-center justify-between mb-8">
          {/* Main Console Tabs */}
          <div className="flex flex-wrap gap-2 w-full md:w-auto">
            {([
              { id: "verification", label: "e-KYC VERIFICATIONS", badge: users.filter(u => u.verificationStatus === "pending").length },
              { id: "workers", label: "WORKER PARTNERS", badge: workers.length },
              { id: "customers", label: "CUSTOMERS LIST", badge: customers.length },
              { id: "support", label: "HELP & SUPPORT DESK", badge: openTicketsCount }
            ] as const).map((tab) => {
              const isSelected = selectedTab === tab.id;
              return (
                <button
                  key={tab.id}
                  onClick={() => setSelectedTab(tab.id)}
                  className={`px-4 py-3 brutalist-border font-black text-xs transition-all brutalist-shadow-sm flex items-center gap-2 ${
                    isSelected ? "bg-black text-[#FFE600] -translate-y-0.5" : "bg-white text-black hover:bg-gray-100"
                  }`}
                >
                  {tab.label}
                  <span className={`px-2 py-0.5 text-[9px] brutalist-border ${isSelected ? "bg-[#FFE600] text-black" : "bg-black text-[#FFE600]"}`}>
                    {tab.badge}
                  </span>
                </button>
              );
            })}
          </div>

          {/* Search box */}
          <div className="relative w-full md:w-80 brutalist-border bg-white brutalist-shadow-sm flex items-center px-3">
            <Search className="w-5 h-5 text-gray-500 mr-2" />
            <input
              type="text"
              placeholder={`SEARCH ${selectedTab.toUpperCase()}...`}
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="py-3 bg-transparent font-bold w-full focus:outline-none text-sm text-black"
            />
          </div>
        </div>

        {/* Database Load Spinner */}
        {loading ? (
          <div className="bg-white brutalist-border brutalist-shadow-lg p-12 text-center">
            <div className="w-12 h-12 border-4 border-black border-t-[#FFE600] rounded-full animate-spin mx-auto mb-4"></div>
            <p className="font-black text-lg">CONNECTING TO SECURE REALTIME DATABASE...</p>
          </div>
        ) : (
          <div>
            {/* View Switching */}
            {filteredData.length === 0 ? (
              <div className="bg-white brutalist-border brutalist-shadow-lg p-16 text-center">
                <Activity className="w-16 h-16 mx-auto text-gray-400 mb-4" />
                <h3 className="text-xl font-black">NO RECORDS FOUND</h3>
                <p className="text-sm font-bold text-gray-500 mt-2">
                  There are no records in this view matching the search criteria.
                </p>
              </div>
            ) : (
              <div>
                {/* 1. E-KYC VERIFICATIONS TAB */}
                {selectedTab === "verification" && (
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {filteredData.map((w) => {
                      const worker = w as UserData;
                      return (
                        <motion.div
                          key={worker.uid}
                          layout
                          className="bg-white brutalist-border brutalist-shadow-lg p-6 flex flex-col justify-between"
                        >
                          <div>
                            <div className="flex justify-between items-start mb-4">
                              <span className={`text-[10px] font-black px-3 py-1 brutalist-border ${
                                worker.verificationStatus === "approved"
                                  ? (worker.role === "customer" ? "bg-blue-500 text-white" : "bg-green-500 text-white")
                                  : worker.verificationStatus === "pending"
                                  ? "bg-orange-500 text-white animate-pulse"
                                  : "bg-red-500 text-white"
                              }`}>
                                {(worker.verificationStatus || "unverified").toUpperCase()}
                              </span>
                              {worker.role !== "customer" && (
                                <span className="text-[10px] font-black bg-black text-[#FFE600] px-3 py-1 brutalist-border">
                                  HUNAR SCORE: {worker.hunarScore || 90}
                                </span>
                              )}
                            </div>

                            <h2 className="text-2xl font-black uppercase leading-none tracking-tight">{worker.name}</h2>
                            <p className="text-xs font-black text-gray-500 uppercase mt-1 mb-3">{worker.role === "customer" ? "CUSTOMER" : worker.category}</p>

                            <div className="text-xs font-bold text-gray-700 space-y-1 mb-4">
                              <p>📱 {worker.phone}</p>
                              <p>📧 {worker.email}</p>
                            </div>

                            {worker.idType && (
                              <div className="bg-gray-50 brutalist-border p-3 mb-4">
                                <div className="flex justify-between items-center mb-1">
                                  <span className="text-[9px] font-black text-gray-400 uppercase">{worker.idType}</span>
                                  <span className="text-[10px] font-black font-mono bg-white px-2 brutalist-border">{worker.idNumber}</span>
                                </div>
                                
                                {worker.idCardPhoto ? (
                                  <div className={worker.idCardPhotoBack ? "grid grid-cols-2 gap-2 mt-2" : "mt-2"}>
                                    <div className="relative brutalist-border bg-black group overflow-hidden h-32 cursor-pointer"
                                         onClick={() => setSelectedPhoto(worker.idCardPhoto || null)}>
                                      <img
                                        src={worker.idCardPhoto.startsWith("data:") ? worker.idCardPhoto : `data:image/jpeg;base64,${worker.idCardPhoto}`}
                                        alt="ID Document Front"
                                        className="w-full h-full object-cover opacity-90 group-hover:scale-105 transition-transform"
                                      />
                                      <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity">
                                        <Eye className="w-6 h-6 text-white" />
                                      </div>
                                      {worker.idCardPhotoBack && (
                                        <div className="absolute bottom-1 left-1 bg-black text-white text-[8px] font-black px-1.5 py-0.5 uppercase brutalist-border">FRONT</div>
                                      )}
                                    </div>
                                    {worker.idCardPhotoBack && (
                                      <div className="relative brutalist-border bg-black group overflow-hidden h-32 cursor-pointer"
                                           onClick={() => setSelectedPhoto(worker.idCardPhotoBack || null)}>
                                        <img
                                          src={worker.idCardPhotoBack.startsWith("data:") ? worker.idCardPhotoBack : `data:image/jpeg;base64,${worker.idCardPhotoBack}`}
                                          alt="ID Document Back"
                                          className="w-full h-full object-cover opacity-90 group-hover:scale-105 transition-transform"
                                        />
                                        <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity">
                                          <Eye className="w-6 h-6 text-white" />
                                        </div>
                                        <div className="absolute bottom-1 left-1 bg-black text-white text-[8px] font-black px-1.5 py-0.5 uppercase brutalist-border">BACK</div>
                                      </div>
                                    )}
                                  </div>
                                ) : (
                                  <div className="border-2 border-dashed border-gray-300 p-4 text-center mt-2 text-xs font-bold text-gray-400">
                                    No Document Photo Uploaded
                                  </div>
                                )}
                              </div>
                            )}
                          </div>

                          <div className="mt-4 pt-4 border-t-2 border-dashed border-gray-200">
                            {worker.verificationStatus === "pending" ? (
                              <div className="flex gap-3">
                                <button
                                  onClick={() => handleApprove(worker.uid)}
                                  className="flex-1 bg-green-500 hover:bg-green-600 text-white font-black text-xs py-3 brutalist-border brutalist-shadow-sm flex items-center justify-center gap-1 cursor-pointer"
                                >
                                  <Check className="w-4 h-4" /> APPROVE
                                </button>
                                <button
                                  onClick={() => handleReject(worker.uid)}
                                  className="flex-1 bg-red-500 hover:bg-red-600 text-white font-black text-xs py-3 brutalist-border brutalist-shadow-sm flex items-center justify-center gap-1 cursor-pointer"
                                >
                                  <X className="w-4 h-4" /> REJECT
                                </button>
                              </div>
                            ) : worker.verificationStatus === "approved" ? (
                              <button
                                onClick={() => handleRevoke(worker.uid)}
                                className="w-full bg-black text-[#FFE600] font-black text-xs py-3 brutalist-border brutalist-shadow-sm hover:bg-gray-900 transition-all flex items-center justify-center gap-1 cursor-pointer"
                              >
                                <XCircle className="w-4 h-4" /> REVOKE VERIFICATION
                              </button>
                            ) : (
                              <div className="text-center py-2 text-xs font-black text-red-500 uppercase bg-red-50 border border-red-200">
                                REJECTED / UNVERIFIED
                              </div>
                            )}
                          </div>
                        </motion.div>
                      );
                    })}
                  </div>
                )}

                {/* 2. WORKERS DIRECTORY TAB */}
                {selectedTab === "workers" && (
                  <div className="space-y-4">
                    {/* Desktop View */}
                    <div className="hidden md:block bg-white brutalist-border brutalist-shadow-lg overflow-x-auto">
                      <table className="w-full text-left border-collapse">
                        <thead>
                          <tr className="bg-black text-[#FFE600] border-b-4 border-black text-xs font-black uppercase">
                            <th className="p-4 border-r-2 border-black">Name</th>
                            <th className="p-4 border-r-2 border-black">Category</th>
                            <th className="p-4 border-r-2 border-black">Contact</th>
                            <th className="p-4 border-r-2 border-black">Verification</th>
                            <th className="p-4 border-r-2 border-black">Hunar Score</th>
                            <th className="p-4 border-r-2 border-black">Status</th>
                            <th className="p-4">Actions</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y-2 divide-black text-xs font-bold">
                          {filteredData.map((w) => {
                            const worker = w as UserData;
                            return (
                              <tr key={worker.uid} className={worker.isDisabled ? "bg-red-50" : "bg-white"}>
                                <td className="p-4 border-r-2 border-black font-black uppercase">{worker.name}</td>
                                <td className="p-4 border-r-2 border-black uppercase text-gray-500">{worker.category}</td>
                                <td className="p-4 border-r-2 border-black space-y-1">
                                  <p className="flex items-center gap-1"><Phone className="w-3.5 h-3.5 text-gray-500" /> {worker.phone}</p>
                                  <p className="flex items-center gap-1"><Mail className="w-3.5 h-3.5 text-gray-500" /> {worker.email}</p>
                                </td>
                                <td className="p-4 border-r-2 border-black">
                                  <span className={`px-2 py-0.5 brutalist-border font-black ${
                                    worker.isVerified ? "bg-green-500 text-white" : "bg-gray-100 text-black"
                                  }`}>
                                    {worker.isVerified ? "VERIFIED" : "UNVERIFIED"}
                                  </span>
                                </td>
                                <td className="p-4 border-r-2 border-black font-mono font-black">{worker.hunarScore ?? 90}</td>
                                <td className="p-4 border-r-2 border-black font-black">
                                  {worker.isDisabled ? (
                                    <span className="text-red-500 uppercase flex items-center gap-1"><UserX className="w-4 h-4" /> DISABLED</span>
                                  ) : (
                                    <span className="text-green-600 uppercase flex items-center gap-1"><UserCheck className="w-4 h-4" /> ACTIVE</span>
                                  )}
                                </td>
                                <td className="p-4 flex gap-2">
                                  <button
                                    onClick={() => handleToggleDisable(worker.uid, worker.isDisabled ?? false)}
                                    className={`p-2 brutalist-border brutalist-shadow-sm font-black transition-all flex items-center gap-1 text-[10px] cursor-pointer ${
                                      worker.isDisabled ? "bg-green-500 hover:bg-green-600 text-white" : "bg-orange-500 hover:bg-orange-600 text-white"
                                    }`}
                                  >
                                    {worker.isDisabled ? <UserCheck className="w-3.5 h-3.5" /> : <UserX className="w-3.5 h-3.5" />}
                                    {worker.isDisabled ? "ENABLE" : "DISABLE"}
                                  </button>
                                  <button
                                    onClick={() => handleDeleteUser(worker.uid)}
                                    className="p-2 bg-red-500 hover:bg-red-600 text-white brutalist-border brutalist-shadow-sm font-black text-[10px] flex items-center gap-1 cursor-pointer"
                                  >
                                    <Trash2 className="w-3.5 h-3.5" /> DELETE
                                  </button>
                                </td>
                              </tr>
                            );
                          })}
                        </tbody>
                      </table>
                    </div>

                    {/* Mobile Card Grid View */}
                    <div className="grid grid-cols-1 gap-4 md:hidden">
                      {filteredData.map((w) => {
                        const worker = w as UserData;
                        return (
                          <div key={worker.uid} className={`bg-white brutalist-border brutalist-shadow-md p-5 ${worker.isDisabled ? "border-red-500" : ""}`}>
                            <div className="flex justify-between items-start mb-3">
                              <div>
                                <h3 className="text-lg font-black uppercase">{worker.name}</h3>
                                <p className="text-[10px] font-black text-gray-400 uppercase">{worker.category}</p>
                              </div>
                              <span className={`px-2 py-0.5 brutalist-border font-black text-[10px] ${
                                worker.isVerified ? "bg-green-500 text-white" : "bg-gray-100 text-black"
                              }`}>
                                {worker.isVerified ? "VERIFIED" : "UNVERIFIED"}
                              </span>
                            </div>
                            <div className="text-xs font-bold text-gray-700 space-y-1 mb-4">
                              <p className="flex items-center gap-1"><Phone className="w-3.5 h-3.5 text-gray-500" /> {worker.phone}</p>
                              <p className="flex items-center gap-1"><Mail className="w-3.5 h-3.5 text-gray-500" /> {worker.email}</p>
                              <p>🏆 HUNAR SCORE: <span className="font-black font-mono">{worker.hunarScore ?? 90}</span></p>
                              <p>🚦 STATUS: <span className={worker.isDisabled ? "text-red-500 font-black" : "text-green-600 font-black"}>{worker.isDisabled ? "DISABLED" : "ACTIVE"}</span></p>
                            </div>
                            <div className="flex gap-2 pt-3 border-t border-dashed border-gray-200">
                              <button
                                onClick={() => handleToggleDisable(worker.uid, worker.isDisabled ?? false)}
                                className={`flex-1 p-2 brutalist-border brutalist-shadow-sm font-black text-center flex items-center justify-center gap-1 text-xs cursor-pointer ${
                                  worker.isDisabled ? "bg-green-500 hover:bg-green-600 text-white" : "bg-orange-500 hover:bg-orange-600 text-white"
                                }`}
                              >
                                {worker.isDisabled ? <UserCheck className="w-4 h-4" /> : <UserX className="w-4 h-4" />}
                                {worker.isDisabled ? "ENABLE" : "DISABLE"}
                              </button>
                              <button
                                onClick={() => handleDeleteUser(worker.uid)}
                                className="flex-1 p-2 bg-red-500 hover:bg-red-600 text-white brutalist-border brutalist-shadow-sm font-black text-center flex items-center justify-center gap-1 text-xs cursor-pointer"
                              >
                                <Trash2 className="w-4 h-4" /> DELETE
                              </button>
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                )}

                {/* 3. CUSTOMERS DIRECTORY TAB */}
                {selectedTab === "customers" && (
                  <div className="space-y-4">
                    {/* Desktop View */}
                    <div className="hidden md:block bg-white brutalist-border brutalist-shadow-lg overflow-x-auto">
                      <table className="w-full text-left border-collapse">
                        <thead>
                          <tr className="bg-black text-[#FFE600] border-b-4 border-black text-xs font-black uppercase">
                            <th className="p-4 border-r-2 border-black">Name</th>
                            <th className="p-4 border-r-2 border-black">Address</th>
                            <th className="p-4 border-r-2 border-black">Contact Details</th>
                            <th className="p-4 border-r-2 border-black">Verification</th>
                            <th className="p-4 border-r-2 border-black">Preferences</th>
                            <th className="p-4 border-r-2 border-black">Status</th>
                            <th className="p-4">Actions</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y-2 divide-black text-xs font-bold">
                          {filteredData.map((c) => {
                            const customer = c as UserData;
                            return (
                              <tr key={customer.uid} className={customer.isDisabled ? "bg-red-50" : "bg-white"}>
                                <td className="p-4 border-r-2 border-black font-black uppercase flex items-center gap-1">
                                  {customer.name}
                                  {customer.isVerified && <span className="text-blue-500 font-extrabold text-sm" title="Verified Customer">✓</span>}
                                </td>
                                <td className="p-4 border-r-2 border-black uppercase text-gray-500">{customer.address ?? "No address listed"}</td>
                                <td className="p-4 border-r-2 border-black space-y-1">
                                  <p className="flex items-center gap-1"><Phone className="w-3.5 h-3.5 text-gray-500" /> {customer.phone}</p>
                                  <p className="flex items-center gap-1"><Mail className="w-3.5 h-3.5 text-gray-500" /> {customer.email}</p>
                                </td>
                                <td className="p-4 border-r-2 border-black">
                                  <span className={`px-2 py-0.5 brutalist-border font-black ${
                                    customer.isVerified ? "bg-blue-500 text-white" : "bg-gray-100 text-black"
                                  }`}>
                                    {customer.isVerified ? "VERIFIED" : "UNVERIFIED"}
                                  </span>
                                </td>
                                <td className="p-4 border-r-2 border-black space-y-1 text-gray-500 uppercase">
                                  <p>Contact: {customer.preferredContact ?? "In-App Chat"}</p>
                                  <p>Slot: {customer.preferredSlot ?? "Morning"}</p>
                                </td>
                                <td className="p-4 border-r-2 border-black font-black">
                                  {customer.isDisabled ? (
                                    <span className="text-red-500 uppercase flex items-center gap-1"><UserX className="w-4 h-4" /> DISABLED</span>
                                  ) : (
                                    <span className="text-green-600 uppercase flex items-center gap-1"><UserCheck className="w-4 h-4" /> ACTIVE</span>
                                  )}
                                </td>
                                <td className="p-4 flex gap-2">
                                  <button
                                    onClick={() => handleToggleDisable(customer.uid, customer.isDisabled ?? false)}
                                    className={`p-2 brutalist-border brutalist-shadow-sm font-black transition-all flex items-center gap-1 text-[10px] cursor-pointer ${
                                      customer.isDisabled ? "bg-green-500 hover:bg-green-600 text-white" : "bg-orange-500 hover:bg-orange-600 text-white"
                                    }`}
                                  >
                                    {customer.isDisabled ? <UserCheck className="w-3.5 h-3.5" /> : <UserX className="w-3.5 h-3.5" />}
                                    {customer.isDisabled ? "ENABLE" : "DISABLE"}
                                  </button>
                                  <button
                                    onClick={() => handleDeleteUser(customer.uid)}
                                    className="p-2 bg-red-500 hover:bg-red-600 text-white brutalist-border brutalist-shadow-sm font-black text-[10px] flex items-center gap-1 cursor-pointer"
                                  >
                                    <Trash2 className="w-3.5 h-3.5" /> DELETE
                                  </button>
                                </td>
                              </tr>
                            );
                          })}
                        </tbody>
                      </table>
                    </div>

                    {/* Mobile Card Grid View */}
                    <div className="grid grid-cols-1 gap-4 md:hidden">
                      {filteredData.map((c) => {
                        const customer = c as UserData;
                        return (
                          <div key={customer.uid} className={`bg-white brutalist-border brutalist-shadow-md p-5 ${customer.isDisabled ? "border-red-500" : ""}`}>
                            <div className="flex justify-between items-start mb-3">
                              <div>
                                <h3 className="text-lg font-black uppercase flex items-center gap-1">
                                  {customer.name}
                                  {customer.isVerified && <span className="text-blue-500 font-extrabold">✓</span>}
                                </h3>
                                <p className="text-[10px] font-bold text-gray-500 uppercase">{customer.address ?? "No address listed"}</p>
                              </div>
                              <span className={`px-2 py-0.5 brutalist-border font-black text-[10px] ${
                                customer.isVerified ? "bg-blue-500 text-white" : "bg-gray-100 text-black"
                              }`}>
                                {customer.isVerified ? "VERIFIED" : "UNVERIFIED"}
                              </span>
                            </div>
                            <div className="text-xs font-bold text-gray-700 space-y-1 mb-4">
                              <p className="flex items-center gap-1"><Phone className="w-3.5 h-3.5 text-gray-500" /> {customer.phone}</p>
                              <p className="flex items-center gap-1"><Mail className="w-3.5 h-3.5 text-gray-500" /> {customer.email}</p>
                              <p className="pt-1 text-[10px] text-gray-500 uppercase">Contact: {customer.preferredContact ?? "In-App Chat"}</p>
                              <p className="text-[10px] text-gray-500 uppercase">Slot: {customer.preferredSlot ?? "Morning"}</p>
                            </div>
                            <div className="flex gap-2 pt-3 border-t border-dashed border-gray-200">
                              <button
                                onClick={() => handleToggleDisable(customer.uid, customer.isDisabled ?? false)}
                                className={`flex-1 p-2 brutalist-border brutalist-shadow-sm font-black text-center flex items-center justify-center gap-1 text-xs cursor-pointer ${
                                  customer.isDisabled ? "bg-green-500 hover:bg-green-600 text-white" : "bg-orange-500 hover:bg-orange-600 text-white"
                                }`}
                              >
                                {customer.isDisabled ? <UserCheck className="w-4 h-4" /> : <UserX className="w-4 h-4" />}
                                {customer.isDisabled ? "ENABLE" : "DISABLE"}
                              </button>
                              <button
                                onClick={() => handleDeleteUser(customer.uid)}
                                className="flex-1 p-2 bg-red-500 hover:bg-red-600 text-white brutalist-border brutalist-shadow-sm font-black text-center flex items-center justify-center gap-1 text-xs cursor-pointer"
                              >
                                <Trash2 className="w-4 h-4" /> DELETE
                              </button>
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                )}

                {/* 4. HELP & SUPPORT DESK TAB */}
                {selectedTab === "support" && (
                  <div className="space-y-6">
                    {filteredData.map((t) => {
                      const ticket = t as SupportTicket;
                      return (
                        <div 
                          key={ticket.ticketId}
                          className="bg-white brutalist-border brutalist-shadow-lg p-6 flex flex-col md:flex-row justify-between gap-6"
                        >
                          <div className="flex-1">
                            <div className="flex items-center gap-2 mb-3">
                              <span className={`text-[10px] font-black px-2 py-0.5 brutalist-border ${
                                ticket.status === "open" ? "bg-red-500 text-white animate-pulse" : "bg-green-500 text-white"
                              }`}>
                                {ticket.status.toUpperCase()}
                              </span>
                              <span className="text-[10px] font-black uppercase text-gray-500">
                                {ticket.role}: {ticket.name}
                              </span>
                            </div>

                            <p className="font-black text-sm bg-gray-50 p-4 brutalist-border border-dashed border-gray-300">
                              💬 {ticket.message}
                            </p>

                            {ticket.adminReply && (
                              <div className="mt-4 p-4 bg-green-50 brutalist-border border-green-500 text-xs font-bold text-gray-800">
                                <p className="font-black text-green-700 uppercase mb-1">Response Sent:</p>
                                <p>✍️ {ticket.adminReply}</p>
                              </div>
                            )}
                          </div>

                          {ticket.status === "open" && (
                            <div className="w-full md:w-80 flex flex-col justify-end">
                              <label className="block text-[10px] font-black uppercase mb-1">Reply to User</label>
                              <textarea
                                placeholder="Type your response solution here..."
                                value={replyTexts[ticket.ticketId] || ""}
                                onChange={(e) => setReplyTexts(prev => ({ ...prev, [ticket.ticketId]: e.target.value }))}
                                className="w-full p-3 bg-gray-50 brutalist-border font-bold text-xs focus:outline-none text-black h-24 mb-3"
                              />
                              <button
                                onClick={() => handleResolveTicket(ticket.ticketId)}
                                className="w-full bg-black text-[#FFE600] font-black text-xs py-3 brutalist-border brutalist-shadow-sm flex items-center justify-center gap-1 cursor-pointer"
                              >
                                <Check className="w-4 h-4" /> RESOLVE & REPLY
                              </button>
                            </div>
                          )}
                        </div>
                      );
                    })}
                  </div>
                )}

              </div>
            )}
          </div>
        )}
      </main>

      {/* Lightbox Modal for Photo viewing */}
      {selectedPhoto && (
        <div
          className="fixed inset-0 bg-black/85 z-50 flex items-center justify-center p-4 cursor-pointer"
          onClick={() => setSelectedPhoto(null)}
        >
          <div className="relative max-w-4xl max-h-[85vh] bg-white p-2 brutalist-border brutalist-shadow-lg">
            <img
              src={selectedPhoto.startsWith("data:") ? selectedPhoto : `data:image/jpeg;base64,${selectedPhoto}`}
              alt="High Resolution ID"
              className="max-w-full max-h-[80vh] object-contain"
            />
            <button
              onClick={() => setSelectedPhoto(null)}
              className="absolute top-4 right-4 bg-white hover:bg-gray-100 text-black font-black p-2 brutalist-border text-xs flex items-center gap-1 z-50 shadow-md"
            >
              <X className="w-4 h-4" /> CLOSE
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
