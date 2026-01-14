const Footer = () => {
	return (
		<footer class="w-full bg-base-200 text-base-content">
			<div class="footer footer-center p-4 border-t border-base-content/5 bg-base-300/20 text-base-content/40 text-sm">
				<aside>
					<p>© {new Date().getFullYear()} - All right reserved by Innovacad.</p>
				</aside>
			</div>
		</footer>
	);
};

export default Footer;
