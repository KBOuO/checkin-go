export function SiteFooter({ fromFallback }: { fromFallback: boolean }) {
  return (
    <footer className="border-t border-cyan-900/10 bg-cyan-50/40 py-10 text-sm text-cyan-900/60">
      <div className="mx-auto flex max-w-6xl flex-col gap-2 px-4 sm:px-6">
        <p className="font-bold text-cyan-900">打卡趣 CheckinGo</p>
        <p>
          本網站為個人作品集示範專案，品牌與「島嶼打卡季」活動皆為虛構；景點資訊僅供示意，出發前請以官方資訊為準。
        </p>
        <p>React (Next.js) × FastAPI × Flutter（App 開發中）</p>
        {fromFallback && (
          <p className="text-orange-600/80">
            ※ 目前顯示內建備援資料（行銷 API 未連線）
          </p>
        )}
      </div>
    </footer>
  );
}
