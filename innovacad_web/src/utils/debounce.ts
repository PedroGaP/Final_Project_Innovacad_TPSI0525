const debounce = (fn: (...args: any[]) => unknown, delay: number) => {
  let _delay: any;

  return (...args: any[]) => {
    clearTimeout(_delay);
    _delay = setTimeout(() => fn(...args), delay);
  };
};

export default debounce;
