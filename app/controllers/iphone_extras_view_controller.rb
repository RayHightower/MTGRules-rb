class IphoneExtrasViewController < UIViewController

  attr_accessor :delegate


  def viewDidLoad
    super

    title = "Rules"
  end


  def configure_view
    lines = @extras_text.split("\n")
    html = "<p>#{lines.join('</p><p>')}</p>"
    self.view.loadHTMLString(html, baseURL: nil)
  end


  def set_extras_text(new_extras_text)
    if @extras_text != new_extras_text
      @extras_text = new_extras_text
      configure_view
    end
  end


end
