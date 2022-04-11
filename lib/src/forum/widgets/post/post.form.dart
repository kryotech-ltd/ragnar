import 'package:flutter/material.dart';
import '../../../../fireflutter.dart';

class PostForm extends StatefulWidget {
  const PostForm({
    this.category,
    this.subcategory,
    this.photo,
    this.post,
    required this.onCreate,
    required this.onUpdate,
    required this.onError,
    this.heightBetween = 10.0,
    this.titleFieldBuilder,
    this.contentFieldBuilder,
    this.submitButtonBuilder,
    Key? key,
  }) : super(key: key);

  final PostModel? post;
  final String? category;
  final String? subcategory;
  final double heightBetween;

  /// If [photo] is set to true, then there must a photo in the post.
  final bool? photo;

  final Function(String) onCreate;
  final Function(String) onUpdate;
  final Function(dynamic) onError;

  final Widget Function(TextEditingController)? titleFieldBuilder;
  final Widget Function(TextEditingController)? contentFieldBuilder;
  final Widget Function(Function())? submitButtonBuilder;
  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final title = TextEditingController();
  final content = TextEditingController();
  final documentId = TextEditingController();
  final summary = TextEditingController();

  late List<String> files = [];

  double uploadProgress = 0;

  bool get isCreate => widget.post == null || widget.post?.id == '';
  bool get isUpdate => !isCreate;

  @override
  void initState() {
    super.initState();
    setState(() {
      title.text = widget.post?.title ?? '';
      content.text = widget.post?.content ?? '';
      summary.text = widget.post?.summary ?? '';
      files = widget.post?.files ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleField = widget.titleFieldBuilder != null
        ? widget.titleFieldBuilder!(title)
        : TextField(controller: title);
    final contentField = widget.contentFieldBuilder != null
        ? widget.contentFieldBuilder!(content)
        : TextField(controller: content, minLines: 3, maxLines: 10);

    final submitButton = widget.submitButtonBuilder != null
        ? widget.submitButtonBuilder!(onSubmit)
        : ElevatedButton(
            onPressed: () => onSubmit(),
            child: const Text('SUBMIT'),
            style: ElevatedButton.styleFrom(elevation: 0),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Title',
          style: TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
        titleField,
        SizedBox(height: widget.heightBetween),
        const Text(
          'Content',
          style: TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
        contentField,
        SizedBox(height: widget.heightBetween),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FileUploadButton(
              child: Icon(
                Icons.camera_alt,
                size: 42,
              ),
              type: 'post',
              onUploaded: (url) {
                files = [...files, url];
                if (mounted)
                  setState(() {
                    uploadProgress = 0;
                  });
              },
              onProgress: (progress) {
                if (mounted) setState(() => uploadProgress = progress);
              },
              onError: widget.onError,
            ),
            submitButton
          ],
        ),
        SizedBox(height: 16),
        if (uploadProgress > 0)
          Column(
            children: [
              LinearProgressIndicator(
                value: uploadProgress,
              ),
              SizedBox(height: 8)
            ],
          ),
        ImageListEdit(files: files, onError: widget.onError),
        if (UserService.instance.user.isAdmin)
          Container(
            margin: EdgeInsets.only(top: 16),
            padding: EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin menu'),
                Divider(color: Colors.grey),
                Text('Document Id'),
                isCreate
                    ? TextField(controller: documentId)
                    : Text(
                        widget.post!.id,
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                SizedBox(height: 16),
                Text('Summary'),
                TextField(controller: summary),
              ],
            ),
          )
      ],
    );
  }

  Future<void> onSubmit() async {
    if (widget.photo == true) {
      if (files.length == 0) {
        widget.onError(ERROR_NO_PHOTO_ATTACHED);
        return;
      }
    }
    try {
      if (widget.category != null && widget.category!.isNotEmpty) {
        /// create
        final ref = await PostModel().create(
          documentId: documentId.text,
          category: widget.category!,
          subcategory: widget.subcategory,
          title: title.text,
          content: content.text,
          summary: summary.text,
          files: files,
        );

        // PostApi.instance.create(category: category, documentId: documentId.text);

        widget.onCreate(ref.id);
      } else {
        /// update
        await widget.post!.update(
          title: title.text,
          content: content.text,
          files: files,
          summary: summary.text,
        );
        widget.onUpdate(widget.post!.id);
      }
    } catch (e) {
      widget.onError(e);
    }
  }
}
