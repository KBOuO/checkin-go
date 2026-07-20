import { fireEvent, render, screen } from "@testing-library/react";
import { SpotCard } from "@/components/SpotCard";
import { useFavorites } from "@/store/favorites";
import type { Spot } from "@/lib/types";

const spot: Spot = {
  id: "xiangshan-trail",
  name: "象山親山步道",
  city: "台北市",
  description: "20 分鐘石階登頂，把台北 101 與整座盆地夜景收進眼底。",
  tags: ["城市夜景", "步道"],
  lat: 25.0273,
  lng: 121.5708,
  checkin_radius_m: 300,
};

describe("SpotCard 收藏", () => {
  beforeEach(() => {
    useFavorites.setState({ ids: [] });
  });

  it("初始未收藏", () => {
    render(<SpotCard spot={spot} index={0} />);
    const button = screen.getByRole("button", { name: "收藏象山親山步道" });
    expect(button).toHaveAttribute("aria-pressed", "false");
  });

  it("點擊後收藏，store 與 UI 同步更新", () => {
    render(<SpotCard spot={spot} index={0} />);
    fireEvent.click(screen.getByRole("button", { name: "收藏象山親山步道" }));

    expect(useFavorites.getState().ids).toContain("xiangshan-trail");
    expect(
      screen.getByRole("button", { name: "取消收藏象山親山步道" }),
    ).toHaveAttribute("aria-pressed", "true");
  });

  it("再次點擊取消收藏", () => {
    render(<SpotCard spot={spot} index={0} />);
    const button = screen.getByRole("button", { name: "收藏象山親山步道" });
    fireEvent.click(button);
    fireEvent.click(screen.getByRole("button", { name: "取消收藏象山親山步道" }));

    expect(useFavorites.getState().ids).not.toContain("xiangshan-trail");
    expect(
      screen.getByRole("button", { name: "收藏象山親山步道" }),
    ).toHaveAttribute("aria-pressed", "false");
  });
});
