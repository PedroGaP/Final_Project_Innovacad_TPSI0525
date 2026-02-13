import Header from "@/components/Header";
import Footer from "@/components/Footer";

const PublicLayout = (props: any) => {
  return (
    <div class="flex flex-col min-h-screen">
      <Header />
      <main class="grow w-full">
        {props.children}
      </main>
      <Footer />
    </div>
  );
};

export default PublicLayout;
