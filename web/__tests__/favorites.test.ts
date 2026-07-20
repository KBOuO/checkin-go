import { useFavorites } from "@/store/favorites";

describe("useFavorites store", () => {
  beforeEach(() => {
    useFavorites.setState({ ids: [] });
    window.localStorage.clear();
  });

  it("初始為空", () => {
    expect(useFavorites.getState().ids).toEqual([]);
  });

  it("toggle 加入收藏", () => {
    useFavorites.getState().toggle("xiangshan-trail");
    expect(useFavorites.getState().ids).toEqual(["xiangshan-trail"]);
  });

  it("再次 toggle 取消收藏", () => {
    useFavorites.getState().toggle("xiangshan-trail");
    useFavorites.getState().toggle("xiangshan-trail");
    expect(useFavorites.getState().ids).toEqual([]);
  });

  it("可同時收藏多個景點，各自獨立切換", () => {
    useFavorites.getState().toggle("xiangshan-trail");
    useFavorites.getState().toggle("jiufen-old-street");
    expect(useFavorites.getState().ids).toEqual([
      "xiangshan-trail",
      "jiufen-old-street",
    ]);

    useFavorites.getState().toggle("xiangshan-trail");
    expect(useFavorites.getState().ids).toEqual(["jiufen-old-street"]);
  });

  it("persist 到 localStorage", () => {
    useFavorites.getState().toggle("xiangshan-trail");
    const stored = window.localStorage.getItem("checkin-go-favorites");
    expect(stored).not.toBeNull();
    expect(JSON.parse(stored!).state.ids).toEqual(["xiangshan-trail"]);
  });
});
