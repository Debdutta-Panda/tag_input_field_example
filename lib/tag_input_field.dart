import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class TagInputController{
  TagInputController({this.initialText = ""});
  final String initialText;
  Function()? onRequestFocus;
  Function()? onRemoveFocus;
  Function(String)? onSetText;
  String Function()? onGetText;
  List<dynamic> Function()? onGetItems;
  Function(List<dynamic>)? onSetItems;

  Function(dynamic)? onAddItem;
  Function(dynamic)? onDeleteItem;
  Function(dynamic,int)? onInsertItem;
  Function(dynamic,dynamic)? onInsertAfter;
  Function(int)? onRemoveAt;

  void removeAt(int index){
    onRemoveAt?.call(index);
  }

  void addItem(dynamic item){
    onAddItem?.call(item);
  }

  void deleteItem(dynamic item){
    onDeleteItem?.call(item);
  }
  void insertItem(dynamic item, int index){
    onInsertItem?.call(item,index);
  }
  void insertAfter(dynamic item, dynamic after){
    onInsertAfter?.call(item,after);
  }

  void requestFocus(){
    onRequestFocus?.call();
  }
  void removeFocus(){
    onRemoveFocus?.call();
  }
  set text(String value){
    onSetText?.call(value);
  }
  String get text{
    return onGetText?.call()??"";
  }
  List<dynamic> get items{
    return onGetItems?.call()??[];
  }
  set items(List<dynamic> list){
    onSetItems?.call(list);
  }
}
class TagInputField extends StatefulWidget {
  const TagInputField(
      {
        this.autocomplete = false,
        this.fieldMinHeight = 60,
        this.fieldDecoration,
        this.fieldPadding = const EdgeInsets.all(8.0),
        this.spacing = 10,
        this.runSpacing = 10,
        this.tagBuilder,
        this.coreFieldMinWidth = 100,
        this.optionViewBuilder,
        this.optionListTopPadding = 16,
        this.optionListElevation = 4,
        this.optionListConstraints,
        this.optionListPadding = EdgeInsets.zero,
        this.optionListMaterialBuilder,
        this.optionBuilder = _defaultOptionBuilder,
        this.coreFieldHeight = 32,
        this.hint = "",
        this.textFieldWrapperBuilder,
        this.inputFormatters,
        required this.onTagAdded,
        required this.onTagDeleted,
        required this.onItemWillBeDeleted,
        this.onChange,
        this.controller,
        required this.onTagsAdded,
        required this.onBeforeTagAdded,
        required this.onBeforeTagsAdded,
        this.onFocusChanged,
        Key? key
      }
      ) : super(key: key);
  final bool autocomplete;
  final double fieldMinHeight;
  final BoxDecoration? fieldDecoration;
  final EdgeInsets fieldPadding;
  final double spacing;
  final double runSpacing;
  final Widget Function(dynamic,Function(dynamic))? tagBuilder;
  final double coreFieldMinWidth;
  final Widget Function(bool,int,dynamic)? optionViewBuilder;
  final double optionListTopPadding;
  final double optionListElevation;
  final BoxConstraints? optionListConstraints;
  final EdgeInsets optionListPadding;
  final Material Function(Widget,double)? optionListMaterialBuilder;
  final Iterable<Object> Function(TextEditingValue) optionBuilder;
  final double coreFieldHeight;
  final String hint;
  final Widget Function(Widget)? textFieldWrapperBuilder;
  final List<TextInputFormatter>? inputFormatters;
  final Function(dynamic) onTagAdded;
  final Function(dynamic) onTagDeleted;
  final bool Function(dynamic) onItemWillBeDeleted;
  final Function(String)? onChange;
  final TagInputController? controller;
  final Function(Iterable<dynamic>) onTagsAdded;
  final bool Function(dynamic) onBeforeTagAdded;
  final bool Function(Iterable<dynamic>) onBeforeTagsAdded;
  final Function(bool)? onFocusChanged;
  @override
  State<TagInputField> createState() => _TagInputFieldState();

  static Iterable<Object> _defaultOptionBuilder(TextEditingValue value){
    return Iterable<Object>.empty();
  }
}

class _TagInputFieldState extends State<TagInputField> {
  var _focusNode = FocusNode();
  var controller = TextEditingController();
  List<dynamic> items = [];
  @override
  Widget build(BuildContext context) {
    return
      LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints)=>Container(
            child: GestureDetector(
              onTap: _onTap,
              child: MouseRegion(
                cursor: SystemMouseCursors.text,
                child: Container(
                  constraints: BoxConstraints(
                      minHeight: widget.fieldMinHeight
                  ),
                  decoration: widget.fieldDecoration ?? _defaultFieldDecoration(),
                  child: Padding(
                    padding: widget.fieldPadding,
                    child: Wrap(
                      runSpacing: widget.runSpacing,
                      spacing: widget.spacing,
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ...items.map(
                                (e) => widget.tagBuilder?.call(e,onDelete)?? _defaultTagWidget(e)
                        ).toList(),
                        IntrinsicWidth(
                          child: Container(
                            constraints: BoxConstraints(
                                minWidth: widget.coreFieldMinWidth
                            ),
                            child: KeyboardListener(
                              focusNode: FocusNode(),
                              onKeyEvent: onKey,
                              child:
                              widget.autocomplete ?
                              AutocompleteWidget()
                                  :(widget.textFieldWrapperBuilder?.call(TextFieldWidget()) ?? TextFieldWidget()),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
      );

  }

  Widget _defaultTagWidget(dynamic e){
    return Container(
      height: 32,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Theme.of(context).colorScheme.secondary
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: IntrinsicWidth(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  e.toString(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary
                  ),
                ),
              ),
              SizedBox(width: 8,),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: ()=>onDelete(e),
                  child: Icon(
                    color: Theme.of(context).colorScheme.onPrimary,
                    Icons.close,
                    size: 16,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget AutocompleteWidget(){
    return Autocomplete<Object>(
      optionsViewBuilder: (
          BuildContext context,
          AutocompleteOnSelected<Object> onSelected,
          Iterable<Object> options
          ) {
        return
          Padding(
            padding: EdgeInsets.only(top: widget.optionListTopPadding),
            child: Align(
              alignment: Alignment.topLeft,
              child: widget.optionListMaterialBuilder?.call(optionListWidget(options,onSelected),widget.optionListElevation) ?? Material(
                elevation: widget.optionListElevation,
                child: optionListWidget(options,onSelected),
              ),
            ),
          );
      },
      optionsBuilder: widget.optionBuilder,
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode fn, VoidCallback onFieldSubmitted) {
        controller = textEditingController;
        _onTextEditingControllerInitialized();
        _focusNode = fn;
        _onFocusNodeInitialized();
        return SizedBox(
          height: widget.coreFieldHeight,
          child: Center(
            child: widget.textFieldWrapperBuilder?.call(_defaultTextFormField(textEditingController,onFieldSubmitted,fn)) ??
                _defaultTextFormField(textEditingController,onFieldSubmitted,fn),
          ),
        );
      },
      onSelected: (dynamic selection) {
        onComma(selection);
      },
    );
  }

  Widget _defaultTextFormField(
      TextEditingController textEditingController,
      VoidCallback onFieldSubmitted,
      FocusNode fn
      ){
    return TextFormField(
      controller: textEditingController,
      decoration: InputDecoration.collapsed(
          hintText: widget.hint
      ),
      focusNode: fn,
      onFieldSubmitted: (String value) {
        onFieldSubmitted();
      },
      inputFormatters:  [
        FilteringTextInputFormatter.allow(_regExp),
        ...(widget.inputFormatters ?? [])
      ],
      onChanged: _onChanged,
    );
  }

  Widget optionListWidget(Iterable<Object> options, AutocompleteOnSelected<Object> onSelected){
    return ConstrainedBox(
      constraints: widget.optionListConstraints ?? _defaultOptionListConstraints(),
      child: ListView.builder(
        padding: widget.optionListPadding,
        shrinkWrap: true,
        itemCount: options.length,
        itemBuilder: (BuildContext context, int index) {
          final Object option = options.elementAt(index);
          return InkWell(
            onTap: () {
              onSelected(option);
            },
            child: Builder(
                builder: (BuildContext context) {
                  final bool highlight = AutocompleteHighlightedOption.of(context) == index;
                  if (highlight) {
                    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
                      Scrollable.ensureVisible(context, alignment: 0.5);
                    });
                  }
                  return widget.optionViewBuilder?.call(highlight,index,option) ?? _defaultOptionWidget(highlight,index,option);
                }
            ),
          );
        },
      ),
    );
  }

  Widget _defaultOptionWidget(bool highlight, int index, Object option){
    return Container(
      color: highlight ? Theme.of(context).focusColor : null,
      padding: const EdgeInsets.all(16.0),
      child: Text(option.toString()),
    );
  }

  void _onTap(){
    _focusNode.requestFocus();
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
  }

  void onKey(KeyEvent event){
    if(event.runtimeType == KeyUpEvent){
      var key = event.logicalKey.keyId;
      switch(key){
      //case 44: onComma(null);break;
      }
    }
    else if(event.runtimeType == KeyDownEvent){
      var key = event.logicalKey.keyId;
      switch(key){
        case 4294967304: onBackSpace();break;
      }
    }
  }

  void onComma(selection) {
    var text = _getText().trim();
    if(text.isEmpty){
      return;
    }
    _setText("");
    setState(() {
      items.add(text);
      widget.onTagAdded(selection??text);
    });
    _onTap();
  }

  void onBackSpace() {
    var selection = controller.selection;
    var start = selection.start;
    var end = selection.end;
    if(start<1 && end<1 && items.isNotEmpty){
      var last = items.last;
      if(!widget.onItemWillBeDeleted(last)){
        return;
      }
      setState(() {
        items.removeLast();
        widget.onTagDeleted(last);
      });
    }
  }

  void onDelete(dynamic e) {
    if(!widget.onItemWillBeDeleted(e)){
      return;
    }
    setState(() {
      items.remove(e);
      widget.onTagDeleted(e);
    });
  }

  TextFieldWidget() {
    return TextField(
      decoration: InputDecoration.collapsed(
          hintText: widget.hint
      ),
      focusNode: _focusNode,
      controller: controller,
      inputFormatters:  [
        FilteringTextInputFormatter.allow(_regExp),
        ...(widget.inputFormatters ?? [])
      ],
      onChanged: _onChanged,
    );
  }

  var _previousValue = "";
  void _notifyTextChanged(String value){
    if(_previousValue==value){
      return;
    }
    _previousValue = value;
    widget.onChange?.call(value);
  }

  _onChanged(String value){
    if(value.contains(",")){
      var list = value.split(",").where((element) => element.isNotEmpty);
      if(list.isNotEmpty){
        _setText("");
        _notifyTextChanged("");
        if(list.length==1){
          if(widget.onBeforeTagAdded(list.first)){
            items.addAll(list);
            setState(() {
              widget.onTagAdded(list.first);
            });
          }
        }
        else{
          if(widget.onBeforeTagsAdded(list))
            items.addAll(list);
          setState(() {
            widget.onTagsAdded(list);
          });
        }
        _onTap();
      }
      else{
        _setText("");
        _notifyTextChanged("");
        _onTap();
      }
    }
    else{
      _notifyTextChanged(value);
    }
  }

  RegExp get _regExp{
    return RegExp(r"[^\s]+[\s]?");
  }

  BoxDecoration _defaultFieldDecoration() {
    return BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.primary)
    );
  }

  BoxConstraints _defaultOptionListConstraints() {
    return BoxConstraints(maxHeight: 200,maxWidth: 200);
  }
  _setText(String value){
    controller.text = value;
  }

  String _getText(){
    return controller.text;
  }
  @override
  void initState() {
    super.initState();
    widget.controller?..onSetItems = (items){
      setState(() {
        this.items = items;
      });
    }
      ..onGetItems = (){
        return items;
      }
      ..onGetText = (){
        return _getText();
      }
      ..onSetText = (value){
        _setText(value);
      }
      ..onRemoveFocus = (){
        _focusNode.unfocus();
      }
      ..onRequestFocus = (){
        _focusNode.requestFocus();
      }
      ..onAddItem = (item){
        setState(() {
          items.add(item);
        });
      }
      ..onDeleteItem = (item){
        if(items.contains(item)){
          setState(() {
            items.remove(item);
          });
        }
      }
      ..onInsertItem = (item,index){
        if(items.length>index-1){
          setState(() {
            items.insert(index, item);
          });
        }
      }
      ..onInsertAfter = (item,after){
        var index = items.indexOf(item);
        if(index > -1){
          setState(() {
            items.insert(index+1, item);
          });
        }
      }
      ..onRemoveAt = (index){
        if(items.length>index&&index > -1){
          setState(() {
            items.removeAt(index);
          });
        }
      }
    ;
  }


  var _controllerInitializedAffected = false;
  var _focusNodeInitializedAffected = false;
  void _onTextEditingControllerInitialized() {
    if(_controllerInitializedAffected){
      return;
    }
    _controllerInitializedAffected = true;
    _setText(widget.controller?.initialText??"");
  }


  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusNodeInitialized() {
    if(_focusNodeInitializedAffected){
      return;
    }
    _focusNodeInitializedAffected = true;
    _focusNode.addListener(_onFocusChanged);
  }

  _onFocusChanged(){
    widget.onFocusChanged?.call(_focusNode.hasFocus);
  }
}