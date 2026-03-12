export const metadata = {
  title: 'Metaplane Test',
  description: 'Security research test app',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
