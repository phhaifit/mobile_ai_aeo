-- Add Vietnamese default writing styles
INSERT INTO "DefaultContentProfile" ("language", "name", "description", "voiceAndTone", "audience")
VALUES
  (
    'vi',
    'Chuyên gia Uy tín',
    'Phong cách viết tự tin, chuyên sâu, giúp định vị thương hiệu như một người dẫn đầu trong ngành. Sử dụng dữ liệu thực tế, cấu trúc rõ ràng và ngôn ngữ uy tín để xây dựng lòng tin với người đọc.',
    'Tự tin, chuyên nghiệp và đáng tin cậy. Giọng văn trang trọng nhưng dễ tiếp cận, mang tính thông tin và có cấu trúc. Sử dụng câu chủ động và khẳng định mạnh mẽ dựa trên bằng chứng. Tránh lạm dụng thuật ngữ chuyên ngành, giải thích các khái niệm phức tạp một cách dễ hiểu.',
    'Chuyên gia kinh doanh, nhà quản lý và lãnh đạo cấp cao. Đối tác tiềm năng và đồng nghiệp trong ngành từ 30-55 tuổi, những người coi trọng chuyên môn, dữ liệu và thông tin hữu ích.'
  ),
  (
    'vi',
    'Nhà Giáo dục Thân thiện',
    'Phong cách viết thân thiện, hấp dẫn, giúp đơn giản hóa các chủ đề phức tạp thành nội dung dễ hiểu. Kết hợp giáo dục với kể chuyện để giữ chân người đọc và mang lại giá trị thực tiễn.',
    'Thân thiện, gần gũi và khích lệ. Giọng văn thoải mái nhưng đầy thông tin, ấm áp và nhiệt tình. Sử dụng ví dụ, so sánh và câu hỏi để thu hút người đọc. Chia nhỏ các ý tưởng phức tạp thành những phần dễ tiếp thu.',
    'Chủ doanh nghiệp nhỏ, nhà tiếp thị và doanh nhân từ 25-45 tuổi. Những người muốn học hỏi và ưa thích nội dung thực tế, có thể áp dụng ngay thay vì lý thuyết suông.'
  )
ON CONFLICT ("language", "name") DO NOTHING;
