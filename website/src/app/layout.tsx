import type { Metadata } from "next";
import { Inter, Outfit } from "next/font/google";
import "./globals.css";

const inter = Inter({
  variable: "--font-sans",
  subsets: ["latin"],
});

const outfit = Outfit({
  variable: "--font-display",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "HunarLoop | India's First AI-Powered Hyperlocal Skill Marketplace",
  description: "Jahan Har Hunar Ki Value Hai. Connect with verified local tutors, plumbers, painters, mehendi artists, and 100+ skills in minutes. Live skill demos and escrow-protected payments.",
  icons: {
    icon: "/logo.svg",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${inter.variable} ${outfit.variable} h-full antialiased`}
    >
      <body className="min-h-full bg-deepdark text-whitetext font-sans flex flex-col">
        {children}
      </body>
    </html>
  );
}
