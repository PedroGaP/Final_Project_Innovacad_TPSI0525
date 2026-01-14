import Header from "@/components/Header";
import Footer from "@/components/Footer";

const PublicLayout = (props: any) => {
  return (
    <div class="flex flex-col min-h-screen">
      <Header />
      <main class="grow flex items-center justify-center">
        {props.children}
      </main>
      <Footer />
    </div>
  );
};

export default PublicLayout;
