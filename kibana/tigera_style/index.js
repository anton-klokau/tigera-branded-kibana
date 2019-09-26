
export default function (kibana) {
  return new kibana.Plugin({
   uiExports: {
     app: {
        title: 'tigera_style',
        order: -100,
        description: 'Tigera Styling',
        main: 'plugins/tigera_style/index.js',
        hidden: true
     }
    }
  });
};
