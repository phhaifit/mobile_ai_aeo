# Báo cáo cá nhân — Phase 1 & Phase 2

> **Hướng dẫn:** copy file này, đổi tên thành `<MSSV>_<GitHub>.md` (vd `22127380_nguyenhuytan2004.md`), đặt vào folder `self-reports/` ở root của repo đề tài (đường dẫn cuối: `self-reports/<MSSV>_<GitHub>.md`). Nếu folder chưa tồn tại, tự tạo. Commit vào branch riêng `self-report/<MSSV>`, tạo PR rồi **tự merge PR của chính mình** (không cần review).
>
> Mục tiêu: bạn tự xác nhận phần đóng góp của mình ở Phase 1 và Phase 2. Đặc biệt quan trọng cho các ticket co-assigned (chia điểm), API thêm/sửa, và những công việc không nằm trong ticket chính thức.

---

## 1. Thông tin cá nhân

| Field | Giá trị |
|---|---|
| Họ tên | Nguyễn Phúc Lợi |
| MSSV | 22127239 |
| GitHub ID | LoiNguyennn |
| Email | nploi22@clc.fitus.edu.vn |
| Đề tài | AEO |
| Nhóm | 7 |
| Repo đề tài | https://github.com/phhaifit/mobile_ai_aeo.git |

---

## 2. Phase 1 — UI + Mock data

### 2.1 Ticket tôi là người implement

> Liệt kê tất cả ticket Phase 1 mà bạn được assign (hoặc đồng-assign). Với mỗi ticket, kê khai phần điểm bạn nhận. Nếu co-assigned, ghi rõ cách chia với bạn cùng đề tài (vd `15/5`).

| # | Issue | Tiêu đề | Estimate | Co-assignee (nếu có) | % chia của tôi | Điểm tôi nhận | PR (link) | Demo / Video |
|---|---|---|---|---|---|---|---|---|
| 1 | #1 | [Phase 1] [Feature 3] Topic / Keyword / Prompt Management | 10 | không | 100% | 10 | https://github.com/phhaifit/mobile_ai_aeo/pull/30 | Demo UI đính kèm trong description của PR |

**Ghi chú thêm về co-assignee split** (nếu có chia không 50/50):
> _vd: "Ticket #8 chia 15/5 với @gankerV vì bạn ấy chỉ làm phần UI form, mình làm phần data layer + tests. Hai bên đã đồng ý qua DM ngày 22/03."_

### 2.2 PR tôi đã review trong Phase 1

> Liệt kê các PR mà bạn đã review approve cho ticket Phase 1 của bạn khác. Theo rule: reviewer được +10% estimate ticket được review (chỉ tính PR đã merge).

| # | PR | Author | Issue được close | Trạng thái review của tôi |
|---|---|---|---|---|
| 1 | #24 | nxt964 | #8 | REQUESTED_CHANGES |
| 2 | #23 | nguyenthaitan | #6 | APPROVED |
| 3 | #31 | kindinh903 | #12 | APPROVED |

### 2.3 Tổng kết Phase 1 (tự chấm)

| Mục | Điểm |
|---|---|
| Implementer | 10 |
| Reviewer bonus | 3 |
| **Tổng (uncapped)** | 13 |
| **Capped @10** | 10 |

---

## 3. Phase 2 — Full-flow integration với API

### 3.1 Ticket tôi là người implement

> Bao gồm cả sub-issue nếu bạn nhận sub-issue thay vì parent. Nếu nhận parent ticket co-assigned, ghi cả parent và sub-issue tương ứng.

| # | Issue | Tiêu đề | Estimate | Co-assignee | % chia của tôi | Điểm tôi nhận | PR (link) | Demo / Video |
|---|---|---|---|---|---|---|---|---|
| 1 | #35 | [Phase 2][Feature 3][Full-integration] Topic / Keyword / Prompt Management | 20 | không | 100% | 10 | https://github.com/phhaifit/mobile_ai_aeo/pull/48 | https://youtu.be/zvC8gewLx-Y |

**Ghi chú co-assignee split / sub-issue split:**
> _vd: "Ticket #57 split qua sub-issue: mình làm sub #68 (15đ), bạn @zoi5161 làm sub #69 (5đ)."_

### 3.2 API tôi đã thêm hoặc chỉnh sửa (Phase 2 BE bonus)

> Theo rule Phase 2: +2đ cho mỗi API thêm mới, +1đ cho mỗi API chỉnh sửa. **Bắt buộc** phải có ticket BE riêng + PR có ≥2 approval.

| # | Loại | Mô tả endpoint | Ticket BE | PR BE (repo) | Đã merge? | Điểm |
|---|---|---|---|---|---|---|
| 1 | _thêm mới / chỉnh sửa_ |  | #__ | #__ |  |  |
| 2 |  |  |  |  |  |  |

### 3.3 PR tôi đã review trong Phase 2

| # | PR | Author | Issue được close | Trạng thái |
|---|---|---|---|---|
| 1 | #52 | nxt964 | #41 | APPROVED |

### 3.4 Tổng kết Phase 2 (tự chấm)

| Mục | Điểm |
|---|---|
| Implementer (FE ticket) | 20 |
| API bonus (BE work) | 0 |
| Reviewer bonus | 2 |
| **Tổng (uncapped)** | 22 |
| **Capped @15** | 15 |

---

## 4. Kê khai bổ sung (nếu có)

> Phần này dành cho các đóng góp **không nằm trong ticket chính thức** nhưng bạn muốn thầy ghi nhận. Vd: bug fix khẩn cấp, refactor lớn, viết docs/test mà nhóm có dùng, support team khác...

| # | Mô tả | Bằng chứng (PR/commit/Slack link) |
|---|---|---|
| 1 | Em đã implement UI ở phase 1 hoàn tất (demo em có để trong phần description của PR), tuy nhiên khi qua phase 2, UI thay đổi gần như toàn bộ, khiến em phải refactor code để có thể align với UI mới. | Demo phase 1 và phase 2 có sự khác biệt về UI, và em có hỏi thầy Hải ở channel 2022_clc_ai_aeo: https://hcmus-se.slack.com/archives/C0AJ7CMLURH/p1776261678356939 |

---

## 5. Đề xuất điều chỉnh điểm (nếu có)

> Phần này để bạn báo các trường hợp ticket / PR mà bạn nghĩ phần kê khai ở §2–§4 chưa phản ánh đúng đóng góp (vd: bạn cùng đề tài được ghi nhận điểm mà thực tế không làm, hoặc ngược lại).

**Ticket / PR cần điều chỉnh:**

| Ticket / PR | Vấn đề | Đề xuất sửa |
|---|---|---|
| #__ | _vd: "Ticket #52 ghi @gankerV co-assignee nhưng thực tế bạn ấy không làm gì, tôi làm hết"_ | _vd: "Tôi nhận 20đ, @gankerV 0đ"_ |

---

## 6. Tự đánh giá & rút kinh nghiệm (tùy chọn)

> Phần optional, không tính điểm — nhưng giúp thầy hiểu hơn về quá trình bạn làm việc.

### Điều bạn làm tốt:

> Em triển khai được end-to-end cho feature Topics/Keywords/Prompts: từ UI điều hướng, model, store đến tích hợp API, đảm bảo luồng thao tác (load, add, delete, restore) có trạng thái rõ ràng. PR phase 1 tập trung vào UI + mock data giúp team review nhanh, còn phase 2 refactor lại để bám theo UI mới và dữ liệu backend thực tế.

### Khó khăn bạn gặp phải:

> UI thay đổi gần như toàn bộ giữa hai phase khiến nhiều component phải viết lại, đồng thời việc đồng bộ projectId và token cho API gây ra lỗi ngầm nếu thiếu dữ liệu. Em phải rà soat luong state va bo sung error/loading de UX khong bi giat.

### Bạn sẽ làm khác đi điều gì nếu được làm lại:

> Em sẽ đề xuất chốt UI sớm hơn hoặc tách layout theo module để giảm refactor khi đổi thiết kế. Ngoài ra em sẽ chuẩn hóa cơ chế lấy token/projectId ngay từ đầu để việc tích hợp API sang phase 2 ít rủi ro hơn.

---

## 7. Cam kết

- [ ] Các thông tin trên là chính xác. Tôi sẽ chịu trách nhiệm nếu phát hiện kê khai sai sự thật (sao chép code, lấy điểm thay người khác, v.v.).
- [ ] Tôi đồng ý cho thầy dùng dữ liệu này để chấm điểm môn LTDDNC 2026.

| Ký tên (gõ tên) | Ngày |
|---|---|
| Nguyễn Phúc Lợi | 16/05/2026 |
