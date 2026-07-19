import { getCurrentCampaign, getSpots } from "@/lib/data";
import { SiteHeader } from "@/components/SiteHeader";
import { Hero } from "@/components/Hero";
import { CampaignIntro } from "@/components/CampaignIntro";
import { HowItWorks } from "@/components/HowItWorks";
import { SpotsSection } from "@/components/SpotsSection";
import { CtaSection } from "@/components/CtaSection";
import { SiteFooter } from "@/components/SiteFooter";

export const revalidate = 3600;

export default async function Home() {
  const [{ spots, fromFallback: spotsFallback }, { campaign, fromFallback }] =
    await Promise.all([getSpots(), getCurrentCampaign()]);

  return (
    <>
      <SiteHeader />
      <main className="flex-1">
        <Hero campaign={campaign} />
        <CampaignIntro campaign={campaign} />
        <HowItWorks />
        <SpotsSection spots={spots} />
        <CtaSection />
      </main>
      <SiteFooter fromFallback={fromFallback || spotsFallback} />
    </>
  );
}
