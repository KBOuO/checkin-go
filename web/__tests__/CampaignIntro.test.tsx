import { render, screen } from "@testing-library/react";
import { CampaignIntro } from "@/components/CampaignIntro";
import type { Campaign } from "@/lib/types";

const campaign: Campaign = {
  id: "island-stamp-2026",
  title: "島嶼打卡季",
  slogan: "集滿島嶼的印章，換一個夏天的故事",
  description: "2026 夏季限定活動說明文字。",
  starts_at: "2026-06-01T00:00:00Z",
  ends_at: "2026-09-30T15:59:59Z",
  stamp_goal: 6,
  reward: "打卡趣限定數位徽章",
  spot_ids: ["xiangshan-trail", "jiufen-old-street"],
};

describe("CampaignIntro", () => {
  it("渲染活動標題與說明", () => {
    render(<CampaignIntro campaign={campaign} />);
    expect(screen.getByText("關於「島嶼打卡季」")).toBeInTheDocument();
    expect(screen.getByText("2026 夏季限定活動說明文字。")).toBeInTheDocument();
  });

  it("日期格式化為西元年月日", () => {
    render(<CampaignIntro campaign={campaign} />);
    // Asia/Taipei（UTC+8）：00:00:00Z → 6/1 08:00；15:59:59Z → 9/30 23:59:59，皆未跨日
    expect(screen.getByText(/2026年6月1日/)).toBeInTheDocument();
    expect(screen.getByText(/2026年9月30日/)).toBeInTheDocument();
  });

  it("顯示集章目標與可蒐集總數", () => {
    render(<CampaignIntro campaign={campaign} />);
    expect(
      screen.getByText(/集滿 6 枚景點印章（共 2 枚可蒐集）/),
    ).toBeInTheDocument();
  });
});
