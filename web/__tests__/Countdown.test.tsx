import { act, render, screen } from "@testing-library/react";
import { Countdown } from "@/components/Countdown";

/** 找到「值格」旁邊標著 label（天/時/分/秒）的文字內容 */
function tileValue(label: string) {
  const labelEl = screen.getByText(label);
  const valueEl = labelEl.previousElementSibling;
  return valueEl?.textContent;
}

describe("Countdown", () => {
  const now = new Date("2026-07-20T00:00:00Z");

  beforeEach(() => {
    jest.useFakeTimers();
    jest.setSystemTime(now);
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it("活動進行中顯示正確的天/時/分/秒", () => {
    // 3 天 4 時 5 分 6 秒後結束（刻意四個數字都不同，避免斷言互相混淆）
    const offsetMs = ((3 * 24 + 4) * 3600 + 5 * 60 + 6) * 1000;
    const endsAt = new Date(now.getTime() + offsetMs).toISOString();
    render(<Countdown endsAt={endsAt} />);
    act(() => {
      jest.advanceTimersByTime(0);
    });

    expect(screen.getByRole("timer", { name: "活動倒數" })).toBeInTheDocument();
    expect(tileValue("天")).toBe("03");
    expect(tileValue("時")).toBe("04");
    expect(tileValue("分")).toBe("05");
    expect(tileValue("秒")).toBe("06");
  });

  it("每秒更新剩餘時間", () => {
    render(<Countdown endsAt="2026-07-20T00:00:10Z" />);
    act(() => {
      jest.advanceTimersByTime(0);
    });

    const secondsBefore = tileValue("秒");
    act(() => {
      jest.advanceTimersByTime(3000);
    });
    const secondsAfter = tileValue("秒");

    expect(secondsBefore).not.toBe(secondsAfter);
  });

  it("活動已結束顯示結束文案，不顯示倒數格", () => {
    render(<Countdown endsAt="2026-07-19T00:00:00Z" />);
    act(() => {
      jest.advanceTimersByTime(0);
    });

    expect(screen.getByText("本季活動已結束，敬請期待下一季")).toBeInTheDocument();
    expect(screen.queryByRole("timer")).not.toBeInTheDocument();
  });
});
