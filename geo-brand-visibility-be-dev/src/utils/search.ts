export const extractSearchQuery = (query: string): string => {
  return query
    ? `${query} (inurl:blog OR inurl:article OR intitle:blog OR intitle:article OR inurl:guides OR intitle:guides) -filetype:pdf -filetype:doc -filetype:docx -filetype:xls -filetype:xlsx -filetype:ppt -filetype:pptx -filetype:csv -filetype:zip`
    : '';
};
